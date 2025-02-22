variable "location" {
  description = "Azure region for resources"
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "at1-rg"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  default     = "vnet1"
}

variable "vnet_address_prefix" {
  description = "Address prefix for the virtual network"
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Name of the subnet"
  default     = "subnet1"
}

variable "subnet_prefix" {
  description = "Address prefix for the subnet"
  default     = "10.0.1.0/24"
}

variable "admin_username" {
  description = "Admin username for VMs"
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for VMs"
  sensitive   = true
}
