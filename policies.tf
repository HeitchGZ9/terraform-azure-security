
#  Enforce Built in Secure transfer to storage accounts should be enabled
resource "azurerm_resource_group_policy_assignment" "enforce_https" {
  name                 = "enforce-https-policy"
  resource_group_id    = azurerm_resource_group.terraform_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"


  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}


#Custom policy for audit VMs & Storage
resource "azurerm_policy_definition" "custom_security_policy" {
  name         = "enforce-security-baseline"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce Security Baseline"
  description  = "Enforce minimum security standards across Azure resources"


  policy_rule = jsonencode({
    if = {
      field = "type"
      in = [
        "Microsoft.Compute/virtualMachines",
        "Microsoft.Storage/storageAccounts"
      ]
    }
    then = {
      effect = "audit"
    }
  })

}