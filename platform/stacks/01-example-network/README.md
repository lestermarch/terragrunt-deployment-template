# 01 Example Network

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
| <a name="module_example_network"></a> [example\_network](#module\_example\_network) | ../../modules/example-network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The short-name of the environment context. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The primary region into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The CIDR range assign as the root address space for the virtual network. | `string` | `"10.24.0.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | A map of private DNS zones to IDs, in the format:<pre>{<br>  privatelink.blob.core.windows.net = "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"<br>  privatelink.example.azure.com      = "/subscriptions/.../privateDnsZones/privatelink.example.azure.com"<br>}</pre> |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group used for this stack. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the virtual network. |
| <a name="output_virtual_network_subnet_ids"></a> [virtual\_network\_subnet\_ids](#output\_virtual\_network\_subnet\_ids) | A map of subnet names to IDs, in the format:<pre>{<br>  SubnetOne = "/subscriptions/.../subnets/SubnetOne"<br>  SubnetTwo = "/subscriptions/.../subnets/SubnetTwo"<br>}</pre> |
<!-- END_TF_DOCS -->
