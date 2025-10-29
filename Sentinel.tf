
//obtain tenantID
data "azurerm_client_config" "current" {}
//Deploy a LAW///
resource "azurerm_log_analytics_workspace" "law" {
  name                = "Tr-law-sec-sen"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "tr-sentinel" {
  workspace_id                 = azurerm_log_analytics_workspace.law.id
  customer_managed_key_enabled = "false"
}

resource "azurerm_sentinel_data_connector_azure_active_directory" "aad_connector" {
  name                       = "aad-connector"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tenant_id                  = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_login" {
  name                       = "suspicious_login_by_malicious_IP"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Non-Trusted Location Sign-Ins with Threat Intel Malicious IPs"
  severity                   = "High"
  query                      = <<-QUERY
let NonTrustedLocationLogin =
union
    (SigninLogs
     | extend DeviceDetailObj = DeviceDetail
     | extend displayName = coalesce(tostring(DeviceDetailObj.displayName), "")
     | extend deviceId = coalesce(tostring(DeviceDetailObj.deviceId), "")
     | extend trustType = coalesce(tostring(DeviceDetailObj.trustType), "")),
    (AADNonInteractiveUserSignInLogs
     | extend DeviceDetailObj = parse_json(DeviceDetail)
     | extend displayName = coalesce(tostring(DeviceDetailObj.displayName), "")
     | extend deviceId = coalesce(tostring(DeviceDetailObj.deviceId), "")
     | extend trustType = coalesce(tostring(DeviceDetailObj.trustType), ""))
| where NetworkLocationDetails !has "trustedNamedLocation" 
| extend 
    authDetails = parse_json(AuthenticationDetails)
| extend succeeded_ = iff(array_length(authDetails) > 0, tostring(authDetails[0].succeeded), "")
| where succeeded_ == "true"
| extend authenticationMethodDetail_ = iff(array_length(authDetails) > 0, tostring(authDetails[0].authenticationMethodDetail), "")
| project TimeGenerated, UserPrincipalName, UserId, deviceId, displayName, trustType, IPAddress, ResultType, ResultSignature, ResultDescription, AppDisplayName, AuthenticationRequirement, AuthenticationProtocol, IsInteractive, ConditionalAccessStatus;
// Threat Intelligence Indicators for IP's as a variable
let TiIndicators =
ThreatIntelIndicators
| extend parsedData = parse_json(Data)
| extend indicatorTypes = parsedData.indicator_types
| where ObservableKey startswith "ipv4-addr" or ObservableKey startswith "ipv6-addr"
| project TimeGenerated, Id, ObservableKey, IPAddress=ObservableValue, Tags, indicatorTypes, Confidence;
// Join IP's from sign-ins with TI
NonTrustedLocationLogin 
| join kind=inner TiIndicators on IPAddress
| project-away TimeGenerated1
| sort by TimeGenerated desc
QUERY
}