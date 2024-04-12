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

# Create the app service plan
resource "azurerm_service_plan" "example" {
  name                = local.resource_name.app_service_plan
  location            = var.location
  resource_group_name = var.resource_group_name

  os_type                  = "Linux"
  per_site_scaling_enabled = var.enable_per_site_scaling
  sku_name                 = var.sku
  worker_count             = var.instances.count
  zone_balancing_enabled   = var.instances.enable_zone_redundancy

  tags = var.resource_tags
}

# Create the app service with private networking
resource "azurerm_linux_web_app" "example" {
  #checkov:skip=CKV_AZURE_13:  Example module
  #checkov:skip=CKV_AZURE_17:  Example module
  #checkov:skip=CKV_AZURE_63:  Example module
  #checkov:skip=CKV_AZURE_65:  Example module
  #checkov:skip=CKV_AZURE_66:  Example module
  #checkov:skip=CKV_AZURE_75:  Example module
  #checkov:skip=CKV_AZURE_88:  Example module
  #checkov:skip=CKV_AZURE_213: Example module
  name                = local.resource_name.app_service
  location            = var.location
  resource_group_name = var.resource_group_name

  app_settings                  = var.app_settings
  https_only                    = true
  public_network_access_enabled = false
  service_plan_id               = azurerm_service_plan.example.id
  virtual_network_subnet_id     = var.app_service_integration_subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on               = true
    ftps_state              = "Disabled"
    http2_enabled           = true
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    vnet_route_all_enabled  = true
  }

  tags = var.resource_tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_linux_web_app.example.id
  subnet_id      = var.app_service_integration_subnet_id
}

resource "azurerm_private_endpoint" "app_service" {
  name                = "pe-${azurerm_linux_web_app.example.name}"
  location            = azurerm_linux_web_app.example.location
  resource_group_name = local.private_endpoint.resource_group_name

  custom_network_interface_name = "pe-nic-${azurerm_linux_web_app.example.name}"
  subnet_id                     = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "pe-${azurerm_linux_web_app.example.name}"
    private_connection_resource_id = azurerm_linux_web_app.example.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink.azurewebsites.net"
    private_dns_zone_ids = var.private_endpoint.private_dns_zone_ids
  }

  tags = var.resource_tags
}
