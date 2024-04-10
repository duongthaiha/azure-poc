output "apim_subnet_id" {
  value = azurerm_subnet.subnet_apim.id  
}

output "openai_subnet_id" {
  value = azurerm_subnet.subnet_openai.id  
}

output "pep_subnet_id" {
  value = azurerm_subnet.subnet_pep.id  
}

output "management_subnet_id" {
  value = azurerm_subnet.subnet_management.id  
}

output "functionapp_subnet_id" {
  value = azurerm_subnet.subnet_functionapp.id  
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "apim_public_ip_id" {
  value = azurerm_public_ip.apim_public_ip.id
}   
