# general
variable "rg_name" {
  description = "The name of the resource group"
  type        = string  
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "aoai_subnet_id" {
  description = "The subnet id of the private endpoint"
  type        = string
}

variable "vnet_id" {
  description = "The id of the virtual network"
  type        = string  
}


# ptu aoai
variable "ptu-aoai-name" {
  description = "The name of the Cognitive Services Account"
  type        = string
  default     = "ptuaoaicogservacc"
}

variable "private_endpoint_ptu_name" {
  description = "The name of the private endpoint"
  type        = string
  default = "pe-ptu-aoai"
}


# payg aoai
variable "payg-aoai-name" {
  description = "The name of the Cognitive Services Account"
  type        = string
  default     = "paygaoaicogservacc"
}

variable "private_endpoint_payg_name" {
  description = "The name of the private endpoint"
  type        = string
  default = "pe-payg-aoai"
}
