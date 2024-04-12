terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Get all location name formats for the deployment region
module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "7.1.1"

  azure_region = var.location
}

# Create a resource group for resources deployed in this stack
resource "azurerm_resource_group" "example_network" {
  name     = "rg-example-network-${local.resource_suffix}"
  location = var.location
}

# Create an network for App Services using the shared network module
module "example_network" {
  source = "../../modules/example-network"

  location            = azurerm_resource_group.example_network.location
  resource_group_name = azurerm_resource_group.example_network.name

  address_space     = var.virtual_network_address_space
  private_dns_zones = ["privatelink.azurewebsites.net"]
}
