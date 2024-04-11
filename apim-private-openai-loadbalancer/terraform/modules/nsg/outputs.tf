output nsg_openai_id {
  value = azurerm_network_security_group.nsg_openai.id
}

output nsg_pep_id {
  value = azurerm_network_security_group.nsg_pep.id
}

output nsg_apim_id {
  value = azurerm_network_security_group.nsg_apim.id
}   