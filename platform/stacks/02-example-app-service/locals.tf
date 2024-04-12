locals {
  # Basic resource suffix to use for resource names
  resource_suffix = "${module.azure_region.location_short}-${var.environment}"
}
