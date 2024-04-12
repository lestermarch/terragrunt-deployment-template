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

# Create an app service plan and app service using the shared module
module "example_app" {
  source = "../../modules/example-app-service"

  location            = azurerm_resource_group.example_network.location
  resource_group_name = azurerm_resource_group.example_network.name

  app_service_integration_subnet_id = var.app_service_integration_subnet_id
  private_endpoint                  = var.app_service_private_endpoint
}
