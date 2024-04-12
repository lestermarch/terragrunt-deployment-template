include {
  path = find_in_parent_folders("deployment.hcl")
}

terraform {
  source = "${get_repo_root()}//platform/stacks/02-example-app-service"
}

dependency "dev_uksouth_01_example" {
  config_path = "${get_repo_root()}//platform/environments/dev/uksouth/01-example-network"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    app_service_integration_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    app_service_private_endpoint = {
      private_dns_zone_ids = [""]
      resource_group_name  = "rg-mock"
      subnet_id            = "/subscriptions/00000000-0000-0000-0000-0000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock/subnets/MockSubnet"
    }
  }
}

inputs = {
  app_service_integration_subnet_id = dependency.dev_uksouth_01_example.virtual_network_subnet_ids["AppServiceIntegrationSubnet"]
  app_service_private_endpoint = {
    private_dns_zone_ids = [dependency.dev_uksouth_01_example.private_dns_zone_ids["privatelink.azurewebsites.net"]]
    resource_group_name  = dependency.dev_uksouth_01_example.resource_group_name
    subnet_id            = dependency.dev_uksouth_01_example.virtual_network_subnet_ids["PrivateEndpointSubnet"]
  }
}
