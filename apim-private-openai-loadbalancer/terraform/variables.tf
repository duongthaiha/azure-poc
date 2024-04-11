# rg name
variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default = "aoai-apim-rg"
}

# location
variable "location" {
  description = "The location of the resource group"
  type        = string
}

# LOG ANALYTICS
variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
  default     = "la-ws-aoai-apim"
}

# VNET
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-aoai-apim"
}

# APIM and APP INSIGHTS
variable "apim_name" {
  description = "The name of the API Management Service"
  type        = string
  default     = "apim-aoai-apim"
}

variable "appinsights_publisher_name" {
  description = "The name of the publisher"
  type        = string
}

variable "appinsights_publisher_email" {
  description = "The email of the publisher"
  type        = string
}