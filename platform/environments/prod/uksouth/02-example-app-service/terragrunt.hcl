include {
  path = find_in_parent_folders("deployment.hcl")
}

terraform {
  source = "${get_repo_root()}//platform/stacks/02-example-storage"
}

dependency "prod_uksouth_01_example" {
  config_path = "${get_repo_root()}//platform/environments/prod/uksouth/01-example-app-service"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs                            = {}
}

inputs = {}
