
//Deploy a LAW///
resource "azurerm_log_analytics_workspace" "law" {
  name                = "Tr-law-sec-sen"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
