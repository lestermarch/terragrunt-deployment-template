include {
  path = find_in_parent_folders("deployment.hcl")
}

terraform {
  source = "${get_repo_root()}//platform/stacks/01-example-network"
}

inputs = {}
