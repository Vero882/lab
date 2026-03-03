variable "region" {
  type        = string
  description = "Default location of Azure resources"
  default     = "westus"
}

variable "vm_size" {
  type        = string
  description = "Default size for Azure VM"
  default     = "Standard_B1ls"
}
