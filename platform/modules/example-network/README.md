# Example Network

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_subnets"></a> [subnets](#module\_subnets) | hashicorp/subnets/cidr | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_integer.entropy](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_pet.resource_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The primary region into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group into which resources will be deployed. | `string` | n/a | yes |
| <a name="input_additional_subnets"></a> [additional\_subnets](#input\_additional\_subnets) | A list of objects describing additional subnets to be deployed, in the format:<pre>[<br>  {<br>    name = "ExampleSubnet"<br>    size = 24<br>  }<br>]</pre> | <pre>list(object({<br>    name = string<br>    size = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The CIDR range assign as the root address space for the virtual network. | `string` | `"10.24.0.0/24"` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | A list of private DNS zone names to create and link to the virtual network. Useful for isolated environments. | `list(string)` | `[]` | no |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | An object used to assign resource names to resources deployed in this module, in the format:<pre>{<br>  virtual_network = "vnet-example"<br>}</pre>Resource names marked as optional will be randomly generated unless specified. | <pre>object({<br>    virtual_network = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of key/value pairs to be assigned as resource tags on taggable resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | A map of private DNS zones to IDs, in the format:<pre>{<br>  privatelink.blob.core.windows.net = "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"<br>  privatelink.example.azure.com      = "/subscriptions/.../privateDnsZones/privatelink.example.azure.com"<br>}</pre> |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | A map of subnet names to IDs, in the format:<pre>{<br>  SubnetOne = "/subscriptions/.../subnets/SubnetOne"<br>  SubnetTwo = "/subscriptions/.../subnets/SubnetTwo"<br>}</pre> |
| <a name="output_subnet_prefixes"></a> [subnet\_prefixes](#output\_subnet\_prefixes) | A map of subnet names to CIDR ranges, in the format:<pre>{<br>  SubnetOne = "10.0.0.0/24"<br>  SubnetTwo = "10.0.1.0/24"<br>}</pre> |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the virtual network. |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the virtual network. |
<!-- END_TF_DOCS -->
