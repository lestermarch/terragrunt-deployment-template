output "app_service_id" {
  description = "The ID of the app service."
  value       = module.example_app.app_service_id
}

output "app_service_plan_id" {
  description = "The ID of the app service plan."
  value       = module.example_app.app_service_plan_id
}

output "resource_group_name" {
  description = "The name of the resource group used for this stack."
  value       = azurerm_resource_group.example_network.name
}
