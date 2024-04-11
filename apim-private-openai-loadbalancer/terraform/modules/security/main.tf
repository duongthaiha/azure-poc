resource "azurerm_key_vault" "keyVault" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enable_rbac_authorization = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_key_vault_secret" "ptuSecret" {
  name         = "aoai-ptu-key"
  value        = var.ptu_aoai_key
  key_vault_id = azurerm_key_vault.keyVault.id
}

resource "azurerm_key_vault_secret" "paygSecret" {
  name         = "aoai-payg-key"
  value        = var.payg_aoai_key
  key_vault_id = azurerm_key_vault.keyVault.id
}

resource "azurerm_private_endpoint" "privateEndpointKeyvault" {
  name                = "pep-keyvault"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.pep_subnet_id

  private_service_connection {
    name                           = "plsConnection"
    private_connection_resource_id = azurerm_key_vault.keyVault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.privateDnsZoneKeyVault.id]
  }
}

resource "azurerm_private_dns_zone" "privateDnsZoneKeyVault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvaultDNSVnetLink" {
  name                  = "vnetLink"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.privateDnsZoneKeyVault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}
