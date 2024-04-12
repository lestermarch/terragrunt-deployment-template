variable "environment" {
  description = "The short-name of the environment context."
  type        = string
}

variable "app_service_integration_subnet_id" {
  description = "The ID of the app service integration subnet for egress traffic."
  type        = string
}

variable "app_service_private_endpoint" {
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

variable "location" {
  description = "The primary region into which resources will be deployed."
  type        = string
}
