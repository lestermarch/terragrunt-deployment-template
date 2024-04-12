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
  value = {
    for k, v in azurerm_private_dns_zone.example :
    k => v.id
  }
}

output "subnet_ids" {
  description = <<-EOT
  A map of subnet names to IDs, in the format:
  ```
  {
    SubnetOne = "/subscriptions/.../subnets/SubnetOne"
    SubnetTwo = "/subscriptions/.../subnets/SubnetTwo"
  }
  ```
  EOT
  value = {
    for k, v in azurerm_subnet.example :
    k => v.id
  }
}

output "subnet_prefixes" {
  description = <<-EOT
  A map of subnet names to CIDR ranges, in the format:
  ```
  {
    SubnetOne = "10.0.0.0/24"
    SubnetTwo = "10.0.1.0/24"
  }
  ```
  EOT
  value = {
    for k, v in azurerm_subnet.example :
    k => one(v.address_prefixes)
  }
}

output "virtual_network_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.example.id
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.example.name
}
