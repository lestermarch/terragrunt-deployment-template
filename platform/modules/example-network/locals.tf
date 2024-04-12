locals {
  # Map of private dns zones to virtual network link names
  private_dns_zones = {
    for zone in var.private_dns_zones :
    zone => {
      link_name = join("_", [
        azurerm_virtual_network.example.name,
        replace(zone, ".", "-")
      ])
    }
  }

  # Generate resource names unless otherwise specified
  resource_name = {
    virtual_network = coalesce(var.resource_name.virtual_network, "vnet-${local.resource_suffix}")
  }

  # Randomised resource suffix to use for generated resource names
  resource_suffix = "${random_pet.resource_suffix.id}-${random_integer.entropy.result}"

  # Calculate the subnets[*].new_bits value for /24 subnets
  subnet_bits = 24 - split("/", var.address_space)[1]

  # Map of subnets to list of delegations to be enabled
  subnet_delegations = {
    AppServiceIntegrationSubnet = {
      provider = "Microsoft.Web/serverFarms"
      actions  = []
    }
  }

  # Map of subnets to list of service endpoints to be enabled
  subnet_service_endpoints = {}

  # Subnet definitions for dynamic provisioning
  subnets = concat(
    [
      {
        # Dedicated to Azure Bastion [/26]
        name     = "AzureBastionSubnet"
        new_bits = local.subnet_bits + 2
      },
      {
        # Dedicated to local management [/26]
        name     = "ManagementSubnet"
        new_bits = local.subnet_bits + 2
      },
      {
        # Dedicated to private endpoints [/26]
        name     = "PrivateEndpointSubnet"
        new_bits = local.subnet_bits + 2
      },
      {
        # Dedicated to App Service VNet integration [/26]
        name     = "AppServiceIntegrationSubnet"
        new_bits = local.subnet_bits + 2
      }
    ],
    [
      # Append any additional subnets [/24 (default)]
      for subnet in var.additional_subnets : {
        name     = subnet.name
        new_bits = coalesce(subnet.size, local.subnet_bits)
      }
    ]
  )
}
