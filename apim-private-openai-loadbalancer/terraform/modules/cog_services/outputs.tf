output "ptu_aoai_key" {
  value = azurerm_cognitive_account.ptu_aoai_cog_serv_acc.primary_access_key
}

output "payg_aoai_key" {
  value = azurerm_cognitive_account.payg_aoai_cog_serv_acc.primary_access_key
}