locals {
  environment_configuration = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  location_configuration    = read_terragrunt_config(find_in_parent_folders("location.hcl"))

  environment = local.environment_configuration.inputs.environment
  location    = local.location_configuration.inputs.location
  stack       = basename(get_terragrunt_dir())
}

remote_state {
  backend = "azurerm"

  config = {
    subscription_id      = "{{stateSubscriptionId}}"
    resource_group_name  = "{{stateResourceGroupName}}"
    storage_account_name = "{{stateStorageAccountName}}"
    container_name       = "{{stateContainerName}}"
    key                  = "${local.environment}/${local.location}/${local.stack}.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

terraform {
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
}

inputs = merge(
  local.environment_configuration.inputs,
  local.location_configuration.inputs,
  {},
)
