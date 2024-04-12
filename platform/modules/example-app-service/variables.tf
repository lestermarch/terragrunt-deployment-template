variable "app_service_integration_subnet_id" {
  description = "The ID of the app service integration subnet for egress traffic."
  type        = string
}

variable "app_settings" {
  default     = {}
  description = <<-EOT
  A map of key/value pairs use as environment variables within the app service, in the format:
  {
    EXAMPLE_PLAINTEXT_KEY       = "ExampleValue"
    EXAMPLE_SECRET_URI_REF_KEY  = @Microsoft.KeyVault(SecretUri=https://kv-example.vault.azure.net/secrets/examplesecret/)
    EXAMPLE_SECRET_NAME_REF_KEY = @Microsoft.KeyVault(VaultName=kv-example;SecretName=examplesecret)
  }
  EOT
  type        = map(any)
}

variable "enable_per_site_scaling" {
  default     = false
  description = "Determines if per-site scaling should be enabled."
  type        = bool
}

variable "location" {
  description = "The primary region into which resources will be deployed."
  type        = string
}

variable "private_endpoint" {
  description = <<-EOT
  An object used to configure a private endpoint for app service ingress traffic, in the format:
  ```
  {
    private_dns_zone_ids = ["/subscriptions/.../privateDnsZones/privatelink.azurewebsites.net"]
    subnet_id            = "/subscriptions/.../subnets/AppServiceIntegrationSubnet"
  }
  ```
  EOT
  type = object({
    private_dns_zone_ids = list(string)
    resource_group_name  = optional(string)
    subnet_id            = string
  })
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
    app_service      = "app-example"
    app_service_plan = "asp-example"
  }
  ```
  Resource names marked as optional will be randomly generated unless specified.
  EOT
  type = object({
    app_service      = optional(string)
    app_service_plan = optional(string)
  })
}

variable "resource_tags" {
  default     = {}
  description = "A map of key/value pairs to be assigned as resource tags on taggable resources."
  type        = map(string)
}

variable "sku" {
  default     = "P0v3"
  description = "The SKU of the app service plan."
  type        = string

  validation {
    condition = contains([
      "B1",
      "B2",
      "B3",
      "P0v3",
      "P1v3",
      "P2v3",
      "P3v3",
      "P1mv3",
      "P2mv3",
      "P3mv3",
      "P4mv3",
      "P5mv3"
    ], var.sku)
    error_message = <<-EOT
    The app service plan SKU must be one of:
    - B1
    - B2
    - B3
    - P0v3
    - P1v3
    - P2v3
    - P3v3
    - P1mv3
    - P2mv3
    - P3mv3
    - P4mv3
    - P5mv3
    EOT
  }
}

variable "instances" {
  default = {
    count                  = 3
    enable_zone_redundancy = true
  }
  description = <<-EOT

  EOT
  type = object({
    count                  = number
    enable_zone_redundancy = bool
  })

  validation {
    condition = (
      (var.instances.enable_zone_redundancy && var.instances.count > 1) ||
      !var.instances.enable_zone_redundancy
    )
    error_message = "Instance count must be a multiple of the number of availability zones when zone redundancy is enabled."
  }
}
