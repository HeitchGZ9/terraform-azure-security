output "resource_group_id" {
  value       = azurerm_resource_group.terraform_rg.id
  description = "ID of the resource group"
}

output "vnet_id" {
  value       = azurerm_virtual_network.terraform_vnet.id
  description = "ID of the virtual network"
}

output "subnet_public_id" {
  value       = azurerm_subnet.subnet_public.id
  description = "ID of the public subnet"
}

output "subnet_private_id" {
  value       = azurerm_subnet.subnet_private.id
  description = "ID of the private subnet"
}

output "nsg_id" {
  value       = azurerm_network_security_group.terraform_netsecgr.id
  description = "ID of the network security group"
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.law.id
  description = "ID of the Log Analytics Workspace"
}

output "log_analytics_workspace_name" {
  value       = azurerm_log_analytics_workspace.law.name
  description = "Name of the Log Analytics Workspace"
}

output "sentinel_alert_rule_ids" {
  value = {
    suspicious_login = azurerm_sentinel_alert_rule_scheduled.suspicious_login.id
    new_vm_created   = azurerm_sentinel_alert_rule_scheduled.new_vm_created.id
  }
  description = "IDs of Sentinel alert rules"
}