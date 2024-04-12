# Example App Service

This module is for example purposes only.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.99.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_web_app.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_private_endpoint.app_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [random_integer.entropy](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_pet.resource_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_integration_subnet_id"></a> [app\_service\_integration\_subnet\_id](#input\_app\_service\_integration\_subnet\_id) | The ID of the app service integration subnet for egress traffic. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The primary region into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | An object used to configure a private endpoint for app service ingress traffic, in the format:<pre>{<br>  private_dns_zone_ids = ["/subscriptions/.../privateDnsZones/privatelink.azurewebsites.net"]<br>  subnet_id            = "/subscriptions/.../subnets/AppServiceIntegrationSubnet"<br>}</pre> | <pre>object({<br>    private_dns_zone_ids = list(string)<br>    resource_group_name  = optional(string)<br>    subnet_id            = string<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of key/value pairs use as environment variables within the app service, in the format:<br>{<br>  EXAMPLE\_PLAINTEXT\_KEY       = "ExampleValue"<br>  EXAMPLE\_SECRET\_URI\_REF\_KEY  = @Microsoft.KeyVault(SecretUri=https://kv-example.vault.azure.net/secrets/examplesecret/)<br>  EXAMPLE\_SECRET\_NAME\_REF\_KEY = @Microsoft.KeyVault(VaultName=kv-example;SecretName=examplesecret)<br>} | `map(any)` | `{}` | no |
| <a name="input_enable_per_site_scaling"></a> [enable\_per\_site\_scaling](#input\_enable\_per\_site\_scaling) | Determines if per-site scaling should be enabled. | `bool` | `false` | no |
| <a name="input_instances"></a> [instances](#input\_instances) |  | <pre>object({<br>    count                  = number<br>    enable_zone_redundancy = bool<br>  })</pre> | <pre>{<br>  "count": 3,<br>  "enable_zone_redundancy": true<br>}</pre> | no |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | An object used to assign resource names to resources deployed in this module, in the format:<pre>{<br>  app_service      = "app-example"<br>  app_service_plan = "asp-example"<br>}</pre>Resource names marked as optional will be randomly generated unless specified. | <pre>object({<br>    app_service      = optional(string)<br>    app_service_plan = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of key/value pairs to be assigned as resource tags on taggable resources. | `map(string)` | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the app service plan. | `string` | `"P0v3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_id"></a> [app\_service\_id](#output\_app\_service\_id) | The ID of the app service. |
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the app service plan. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of the private endpoint used for app service ingress traffic. |
<!-- END_TF_DOCS -->
