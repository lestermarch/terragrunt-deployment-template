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
  mock_outputs                            = {}
}

inputs = {}
