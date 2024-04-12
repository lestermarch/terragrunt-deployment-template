# 01 Example App Service

This stack is for example purposes only.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.99.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_region"></a> [azure\_region](#module\_azure\_region) | claranet/regions/azurerm | 7.1.1 |
| <a name="module_example_app"></a> [example\_app](#module\_example\_app) | ../../modules/example-app-service | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_integration_subnet_id"></a> [app\_service\_integration\_subnet\_id](#input\_app\_service\_integration\_subnet\_id) | The ID of the app service integration subnet for egress traffic. | `string` | n/a | yes |
| <a name="input_app_service_private_endpoint"></a> [app\_service\_private\_endpoint](#input\_app\_service\_private\_endpoint) | An object used to configure a private endpoint for app service ingress traffic, in the format:<pre>{<br>  private_dns_zone_ids = ["/subscriptions/.../privateDnsZones/privatelink.azurewebsites.net"]<br>  subnet_id            = "/subscriptions/.../subnets/AppServiceIntegrationSubnet"<br>}</pre> | <pre>object({<br>    private_dns_zone_ids = list(string)<br>    resource_group_name  = optional(string)<br>    subnet_id            = string<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The short-name of the environment context. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The primary region into which resources will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_id"></a> [app\_service\_id](#output\_app\_service\_id) | The ID of the app service. |
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the app service plan. |
<!-- END_TF_DOCS -->
