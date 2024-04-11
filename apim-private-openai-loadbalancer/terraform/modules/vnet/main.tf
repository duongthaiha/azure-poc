#vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

# apim subnet and nsg association
resource "azurerm_subnet" "subnet_apim" {
  name                 = "snet-apim"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = "10.0.0.0/25"
}

resource "azurerm_subnet_network_security_group_association" "subnet_apim_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_apim.id
  network_security_group_id = var.nsg_apim_id
}

# openai subnet and nsg association
resource "azurerm_subnet" "subnet_openai" {
  name                 = "snet-openai"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = "10.0.1.0/26"
}

resource "azurerm_subnet_network_security_group_association" "subnet_openai_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_openai.id
  network_security_group_id = var.nsg_openai_id
}

# pep subnet and nsg association
resource "azurerm_subnet" "subnet_pep" {
  name                 = "snet-pep"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = "10.0.2.0/24"
}

resource "azurerm_subnet_network_security_group_association" "subnet_pep_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_pep.id
  network_security_group_id = var.nsg_pep_id
}

# subnet for management
resource "azurerm_subnet" "subnet_management" {
  name                 = "snet-management"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = "10.0.3.0/26"
}

# subnet for function app
resource "azurerm_subnet" "subnet_functionapp" {
  name                 = "snet-functionapp"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = "10.0.4.0/25"
  service_endpoints    = ["Microsoft.Web/serverFarms"]
}

# subnet for bastion
resource "azurerm_subnet" "subnet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = "10.0.0.128/26"
}


# public ip for apim management
resource "azurerm_public_ip" "apim_public_ip" {
  name                = "pip-apim-management"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.apim_name
  ip_version          = "IPv4"
}