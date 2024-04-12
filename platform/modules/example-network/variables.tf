variable "additional_subnets" {
  default     = []
  description = <<-EOT
  A list of objects describing additional subnets to be deployed, in the format:
  ```
  [
    {
      name = "ExampleSubnet"
      size = 24
    }
  ]
  ```
  EOT
  type = list(object({
    name = string
    size = optional(number)
  }))
}

variable "address_space" {
  default     = "10.24.0.0/24"
  description = "The CIDR range assign as the root address space for the virtual network."
  type        = string
}

variable "location" {
  default     = "uksouth"
  description = "The primary region into which resources will be deployed."
  type        = string
}

variable "private_dns_zones" {
  default     = []
  description = "A list of private DNS zone names to create and link to the virtual network. Useful for isolated environments."
  type        = list(string)
}

variable "resource_group_name" {
  description = "The name of the resource group into which resources will be deployed."
  type        = string
}

variable "resource_name" {
  default     = {}
  description = <<-EOT
  An object used to assign resource names to resources deployed in this module, in the format:
  ```
  {
    virtual_network = "vnet-example"
  }
  ```
  Resource names marked as optional will be randomly generated unless specified.
  EOT
  type = object({
    virtual_network = optional(string)
  })
}

variable "resource_tags" {
  default     = {}
  description = "A map of key/value pairs to be assigned as resource tags on taggable resources."
  type        = map(string)
}
