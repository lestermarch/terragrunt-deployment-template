locals {
  # Use a different resource group for the private endpoint if specified
  private_endpoint = {
    resource_group_name = coalesce(var.private_endpoint.resource_group_name, var.resource_group_name)
  }

  # Generate resource names unless otherwise specified
  resource_name = {
    app_service      = coalesce(var.resource_name.app_service, "app-${local.resource_suffix}")
    app_service_plan = coalesce(var.resource_name.app_service_plan, "asp-${local.resource_suffix}")
  }

  # Randomised resource suffix to use for generated resource names
  resource_suffix = "${random_pet.resource_suffix.id}-${random_integer.entropy.result}"
}
