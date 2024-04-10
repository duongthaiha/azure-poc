terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.34.0"
        }
    }
}

provider "azurerm" {
    features {}    
}




# resource group
resource "azurerm_resource_group" "rg" {
    name     = var.rg_name
    location = var.location
}


module "log_analytics" {
  source = "./modules/log_analytics"
  // Pass necessary variables
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  log_analytics_ws_name = var.log_analytics_workspace_name
}

module "application_insights" {
  source = "./modules/apim"
  // Pass necessary variables
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  publisher_email = var.appinsights_publisher_email
  publisher_name = var.appinsights_publisher_name
  apim_name = var.apim_name
  apim_subnet_id = module.virtual_network.apim_subnet_id
  public_ip_id = module.virtual_network.apim_public_ip_id
}

module "network_security_groups" {
  source = "./modules/nsg"
  // Pass necessary variables
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

module "virtual_network" {
  source = "./modules/vnet"
  // Pass necessary variables
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  vnet_name = var.vnet_name
  nsg_apim_id = module.network_security_groups.nsg_apim_id
  nsg_openai_id = module.network_security_groups.nsg_openai_id
  nsg_pep_id = module.network_security_groups.nsg_pep_id
  apim_name = module.application_insights.apim_name
}

# I created it insight in the app insights module
#module "api_management" {
#  source = "./modules/api_management"
#  // Pass necessary variables
#}

module "cognitive_services" {
  source = "./modules/cog_services"
  // Pass necessary variables
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  aoai_subnet_id = module.virtual_network.aoai_subnet_id
  vnet_id = module.virtual_network.vnet_id
}