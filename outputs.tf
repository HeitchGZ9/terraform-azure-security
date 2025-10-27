output "resource_group_id" {
  value = azurerm_resource_group.terraform_rg.id
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