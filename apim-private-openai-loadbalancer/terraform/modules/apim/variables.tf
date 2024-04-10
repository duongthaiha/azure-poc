variable "rg_name" {
  description = "The name of the resource group"
  type        = string  
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}


# apim
variable "apim_name" {
  description = "The name of the API Management Service"
  type        = string
}

variable "publisher_name" {
  description = "The name of the publisher"
  type        = string
}

variable "publisher_email" {
  description = "The email of the publisher"
  type        = string
}

variable "apim_subnet_id" {
  description = "The subnet id"
  type        = string
}

variable "public_ip_id" {
  description = "The public ip id"
  type        = string
}


# app insights
variable "app_insights_name" {
  description = "The name of the Application Insights"
  type        = string
  default = "appinsights-apim-aoai"
}