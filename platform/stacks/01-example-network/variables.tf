variable "environment" {
  description = "The short-name of the environment context."
  type        = string
}

variable "location" {
  description = "The primary region into which resources will be deployed."
  type        = string
}

variable "virtual_network_address_space" {
  default     = "10.24.0.0/24"
  description = "The CIDR range assign as the root address space for the virtual network."
  type        = string
}
