output "app_service_id" {
  description = "The ID of the app service."
  value       = azurerm_linux_web_app.example.id
}

output "app_service_plan_id" {
  description = "The ID of the app service plan."
  value       = azurerm_service_plan.example.id
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint used for app service ingress traffic."
  value       = azurerm_private_endpoint.app_service.id
}
