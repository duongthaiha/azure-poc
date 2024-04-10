# general vars
variable "rg_name" {
  description = "The name of the resource group"
  type        = string  
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}



# Log Analytics specific vars
variable "log_analytics_ws_name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
  default     = "acctest-01"
}
