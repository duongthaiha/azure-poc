variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string  
}

variable "rg_name" {
  description = "The name of the resource group"
  type        = string  
}

variable "nsg_apim_id" {
  description = "The id of the APIM NSG"
  type        = string
}

variable "nsg_openai_id" {
  description = "The id of the OpenAI NSG"
  type        = string
}

variable "nsg_pep_id" {
  description = "The id of the pep NSG"
  type        = string
}

variable "apim_name" {
  description = "The name of the API Management Service"
  type        = string  
}

