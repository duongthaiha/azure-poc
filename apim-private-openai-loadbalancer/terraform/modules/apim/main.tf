# app insights
resource "azurerm_application_insights" "appinsights" {
  name                = "appinsights-apim-aoai"
  location            = var.location
  resource_group_name = var.rg_name
  application_type    = "web"
  
}



#apim
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.rg_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  public_ip_address_id = var.public_ip_id
  sku_name = "Developer_1"

  identity {
    type = "SystemAssigned"
  }


  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.apim_subnet_id
  }
}


resource "azurerm_api_management_logger" "apim_logger" {
  name                = "example-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.rg_name
  resource_id         = azurerm_application_insights.appinsights.id

  application_insights {
    instrumentation_key = azurerm_application_insights.appinsights.instrumentation_key
  }
}



resource "azurerm_api_management_diagnostic" "apim_diagnostic" {
  identifier           = var.app_insights_name
  api_management_name  = azurerm_api_management.apim.name
  resource_group_name  = var.rg_name
  api_management_logger_id  = azurerm_api_management_logger.apim_logger.id

  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "verbose"
  http_correlation_protocol = "W3C"
  sampling_percentage       = 100.0

  frontend_request {}
  frontend_response {}
  backend_request {}
  backend_response {}

}


