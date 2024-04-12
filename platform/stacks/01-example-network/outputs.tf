output "private_dns_zone_ids" {
  description = <<-EOT
  A map of private DNS zones to IDs, in the format:
  ```
  {
    privatelink.blob.core.windows.net = "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"
    privatelink.example.azure.com      = "/subscriptions/.../privateDnsZones/privatelink.example.azure.com"
  }
  ```
  EOT
  value       = module.example_network.private_dns_zone_ids
}

output "resource_group_name" {
  description = "The name of the resource group used for this stack."
  value       = azurerm_resource_group.example_network.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network."
  value       = module.example_network.virtual_network_id
}

output "virtual_network_subnet_ids" {
  description = <<-EOT
  A map of subnet names to IDs, in the format:
  ```
  {
    SubnetOne = "/subscriptions/.../subnets/SubnetOne"
    SubnetTwo = "/subscriptions/.../subnets/SubnetTwo"
  }
  ```
  EOT
  value       = module.example_network.subnet_ids
}
