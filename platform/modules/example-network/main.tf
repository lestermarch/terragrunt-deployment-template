terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Generate a random integer and pet name for default resource names
resource "random_integer" "entropy" {
  min = 100
  max = 999
}

resource "random_pet" "resource_suffix" {}

# Generate subnets based on an address space and subnet definition
module "subnets" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = var.address_space
  networks        = local.subnets
}

# Create the virtual network
resource "azurerm_virtual_network" "example" {
  name                = local.resource_name.virtual_network
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [var.address_space]

  tags = var.resource_tags
}

# Dynamically create subnets based on subnet definition
resource "azurerm_subnet" "example" {
  for_each = module.subnets.network_cidr_blocks

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes  = [each.value]
  service_endpoints = try(local.subnet_service_endpoints[each.key], [])

  dynamic "delegation" {
    for_each = (
      can(local.subnet_delegations[each.key]) ?
      [local.subnet_delegations[each.key]] :
      []
    )

    content {
      name = replace(delegation.value.provider, "/", ".")

      service_delegation {
        name    = delegation.value.provider
        actions = try(delegation.value.actions, [])
      }
    }
  }

  lifecycle {
    ignore_changes = [
      delegation[0].service_delegation[0].actions
    ]
  }
}

# Dynamically create and link private DNS zones if specified
resource "azurerm_private_dns_zone" "example" {
  for_each = local.private_dns_zones

  name                = each.key
  resource_group_name = var.resource_group_name

  tags = var.resource_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  for_each = local.private_dns_zones

  name                  = each.value.link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.key
  virtual_network_id    = azurerm_virtual_network.example.id

  tags = var.resource_tags

  depends_on = [
    azurerm_private_dns_zone.example
  ]
}
