variable "rg_name" {
  description = "resource group name"
  type        = string
}

variable "location" {
  description = "location"
  type        = string
}

variable "key_vault_name" {
  description = "key vault name"
  type        = string
}

variable "ptu_aoai_key" {
  description = "ptu aoai key"
  type        = string  
}

variable "payg_aoai_key" {
  description = "payg aoai key"
  type        = string  
}

variable "pep_subnet_id" {
  description = "subnet id of the private endpoint"
  type        = string
}

variable "vnet_id" {
  description = "id of the virtual network"
  type        = string  
}