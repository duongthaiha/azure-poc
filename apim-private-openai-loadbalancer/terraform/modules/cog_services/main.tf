# PTU AOAI
resource "azurerm_cognitive_account" "ptu_aoai_cog_serv_acc" {
  name                = var.ptu-aoai-name
  location            = var.location
  resource_group_name = var.rg_name
  kind                = "OpenAI"
  sku_name = "S0"

  custom_subdomain_name = var.ptu-aoai-name
  public_network_access_enabled = false
}

resource "azurerm_cognitive_deployment" "ptu_gtp35_deployment" {
  name                 = "gpt-35-turbo"
  cognitive_account_id = azurerm_cognitive_account.ptu_aoai_cog_serv_acc.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0301"
  }

  scale {
    type = "Standard"
    capacity = 1
  }
}

resource "azurerm_private_endpoint" "pe_ptu_aoai" {
  name                = var.private_endpoint_ptu_name
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.aoai_subnet_id
  
  private_service_connection {
    name                           = "plsConnectionAOAI"
    private_connection_resource_id = azurerm_cognitive_account.ptu_aoai_cog_serv_acc.id
    subresource_names              = ["gpt-35-turbo"]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name                = "ptu_dnsz_group_default"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dnsz_aoai.id]
  }
}

resource "azurerm_private_dns_zone" "private_dnsz_aoai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "ptu_dnsz_vnet_link" {
    name                  = "aoai-dnsz-vnet-link"
    resource_group_name   = var.rg_name
    private_dns_zone_name = azurerm_private_dns_zone.private_dnsz_aoai.name
    virtual_network_id    = var.vnet_id
    registration_enabled = false
}

# PAYG AOAI
resource "azurerm_cognitive_account" "payg_aoai_cog_serv_acc" {
  name                = var.payg-aoai-name
  location            = var.location
  resource_group_name = var.rg_name
  kind                = "OpenAI"
  sku_name = "S0"

  custom_subdomain_name = var.payg-aoai-name
  public_network_access_enabled = false
}

resource "azurerm_cognitive_deployment" "payg_gtp35_deployment" {
  name                 = "gpt-35-turbo"
  cognitive_account_id = azurerm_cognitive_account.payg_aoai_cog_serv_acc.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0301"
  }

  scale {
    type = "Standard"
    capacity = 1
  }
}

resource "azurerm_private_endpoint" "pe_payg_aoai" {
  name                = var.private_endpoint_payg_name
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.aoai_subnet_id
  
  private_service_connection {
    name                           = "plsConnectionAOAI"
    private_connection_resource_id = azurerm_cognitive_account.payg_aoai_cog_serv_acc.id
    subresource_names              = ["gpt-35-turbo"]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name                = "payg_dnsz_group_default"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dnsz_aoai.id]
  }
}




