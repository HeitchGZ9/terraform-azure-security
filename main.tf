terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource Group
resource "azurerm_resource_group" "terraform_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    enviroment = "dev"
  }
}
#Virtual Network 1
resource "azurerm_virtual_network" "terraform_vnet" {
  name                = "network_1"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  tags = {
    enviroment = "dev"
  }
}

#subnet 1 - Public
resource "azurerm_subnet" "subnet_public" {
  name                 = "security-subnet-public"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
#subnet 2 - Private
resource "azurerm_subnet" "subnet_private" {
  name                 = "security-subnet-public"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


# Network Security Group (NSG)
resource "azurerm_network_security_group" "terraform_netsecgr" {
  name                = "net_sec_group_1"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  tags = {
    enviroment = "dev"
  }
}


resource "azurerm_network_security_rule" "NSG_rule_1" {
  name                        = "access_test_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.terraform_rg.name
  network_security_group_name = azurerm_network_security_group.terraform_netsecgr.name
}

# Associate NSG with Public Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc_public" {
  subnet_id                 = azurerm_subnet.subnet_public.id
  network_security_group_id = azurerm_network_security_group.terraform_netsecgr.id
}

resource "azurerm_public_ip" "public_ip_1" {
  name                    = "first_ip"
  location                = azurerm_resource_group.terraform_rg.location
  resource_group_name     = azurerm_resource_group.terraform_rg.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 30


  tags = {
    environment = "dev"
  }

}

resource "azurerm_network_interface" "nic_1" {
  name                = "nic_1"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
  }
  tags = {
    environment = "dev"
  }

}


