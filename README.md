# Terragrunt Deployment Template

This repository provides an example structure for using [Terragrunt](https://terragrunt.gruntwork.io/) to orchestrate multiple Terraform deployments in a way that increases the scalability of Terraform whilst minimising the increase in management overhead.

> [!Note]
> This repository is designed for deployments to Microsoft Azure, but may be adapted for use with other public or private cloud providers.

## Problem Statement

Terraform is a powerful tool for provisioning infrastructure. However, Terraform must track the state of resources in a state file and reconcile this state for every deployment. As Terraform deployments grow larger, so to does the state file, and eventually each deployment can become slow or problematic.

Similarly, there is often good reason to break down infrastructure into stacks, where each stack represents a set of infrastructure components which share a common lifecycle, and which may even be maintained by different teams. This is not well supported in native Terraform, instead requiring separate Terraform deployments and creating custom automation to string deployments together (e.g. through GitHub Actions).

### Solution

The solution proposed here is to use Terragrunt as a "wrapper" for multiple Terraform deployments (stacks). Terragrunt effectively acts as an orchestrator, handling dependencies between stacks, and ensuring each stack gets its own state file. In this way, state file sizes are minimised, and large-scale deployments can be easily democratised by allowing separate teams to manage one or more stacks of infrastructure themselves.

The notion of orchestrating Terraform stacks is extended further in this solution by logically associating stacks to a region which in turn is associated to an environment to describe, in deployment terms, the relationship between the stacks of infrastructure being deployed and the environment/region they are being deployed into.

## Repository Structure

The below diagram highlights the core structure of this repository. Configuration files have been omitted for brevity:

```
.
├── <workload>
└── platform
    ├── environments
    |   ├── <env>
    |   |   ├── <region>
    |   |   |   ├── <stack>
    |   |   |   |   └── terragrunt.hcl
    |   |   |   └── location.hcl
    |   |   └── environment.hcl
    |   └── deployment.hcl
    |
    ├── modules
    |   └── <module>
    |       ├── locals.tf
    |       ├── output.tf
    |       ├── main.tf
    |       ├── README.md
    |       └── variables.tf
    |
    └── stacks
        └── <stack>
            ├── locals.tf
            ├── output.tf
            ├── main.tf
            ├── README.md
            └── variables.tf
```

### Modules

The [modules](/platform/modules/) directory contains one or more subdirectories of local (unpublished) Terraform modules.

Modules should have the following characteristics:

- Environment-agnostic and location-agnostic.
- Deploy a specific resource, and any supporting resources, in a best-practice configuration by default.
- Designed for re-use across stacks by providing appropriate variables to offer a reasonable degree of customisation.

For example, an app service plan module might configure zone-redundancy and multiple instances by default but offer variables to downgrade or disable this behaviour for workloads where this is not required.

> [!Tip]
> Local modules are not necessary for cases where you are using modules from a registry, such as the [Terraform public registry](https://registry.terraform.io/).

### Stacks

The [stacks](/platform/stacks/) directory contains one or more subdirectories of Terraform deployments (stacks).

Stacks should have the following characteristics:

- Environment-agnostic and location-agnostic.
- Deploy one or more modules (each containing one or more resources), in a best-practice configuration by default.
- Designed for re-use across environments by providing appropriate variables to offer a reasonable degree of customisation.

For example, a stack which deploys a virtual network should "pass-through" the variable for configuring the virtual network address space from the virtual network module to the stack variables such that the address space may be configured differently per-environment.

> [!Tip]
> It is recommended to prefix stacks with a number to highlight the deployment/dependency order between stacks.

### Environments

The [environments](/platform/environments/) directory contains one or more subdirectories representing deployment environments (e.g. `dev`, `prod`). A `deployment.hcl` file contains the root-level Terragrunt configuration. This includes a reference to the shared remote state configuration and merging of environment-level and region-level variables. Variable inputs which should be applied globally may be defined here.

Each environment subdirectory contains one or more subdirectories representing deployment locations (e.g. `uksouth`, `ukwest`). A `environment.hcl` file contains the environment-level Terragrunt configuration. Variable inputs which should be applied to all stacks in the environment may be defined here.

Each location subdirectory contains one or more subdirectories of Terraform deployments (stacks). A `location.hcl` contains the region-level Terragrunt configuration. Variable inputs which should be applied to all stacks in the region may be defined here.

Each stack subdirectory contains a `terragrunt.hcl` file with the stack-level configuration. This includes a reference to the stack directory being deployed, as well as any dependencies on stacks, whether they be in the same environment and region or other environments and regions. Variable inputs specific to the stack may be defined here.

## Usage

The below sections describe how to use this deployment methodology either manually or through GitHub Actions, allowing you to scope your deployments appropriately.

> [!Note]
> Before running deployments, please see the [platform](/platform/) documentation for guidance on pre-requisite setup, including creating a managed identity for deployments, a storage account for shared state, and initial Terragrunt configuration.

### Manually Scoped Deployments

Deployments can either be performed against all environments, specific environments, specific regions within an environment, or a specific stack within an environment region.

The below sections provide example of manual scoped deployments. However, the same command can be used in scripts and run using pipeline tooling (e.g. GitHub Actions or Azure DevOps Pipelines). A GitHub Action for deployments is already provided and described later in this document.

> [!Warning]
> Manual deployments are not recommended. It is common for separate Azure subscriptions to be used per-environment. When running manual deployments, make sure you are scoped to the appropriate subscription using `az account set -s <subscriptionId>` and `az account show`.

#### Stack Deployment

The most targeted deployment approach is to deploy a specific stack within an environment region. This can be achieved by calling Terragrunt from the desired stack directory in the target environment region:

```
terragrunt apply --terragrunt-working-dir environments/<env>/<location>/<stack>
```

#### Region Deployment

For cases where you want to deploy all resources in a specific environment region, call Terragrunt from the desired region directory in the target environment:

```
terragrunt run-all apply --terragrunt-working-dir environments/<env>/<location>
```

#### Environment Deployment

For cases where you want to deploy all resources in a specific environment, call Terragrunt from the desired environment directory:

```
terragrunt run-all apply --terragrunt-working-dir environments/<env>
```

#### Full Deployment

For cases where you want to deploy all environments, call Terragrunt from the [environments](/platform/environments/) directory:

```
terragrunt run-all apply --terragrunt-working-dir environments
```

### Deployment Pipeline

The [deployment pipeline](.github/workflows/platform-deployment.yaml) offers a semi-automated solution for deploying your workload at the desired scope (stack, region, environment, or everything).

#### Environments

GitHub uses the notion of environments to run jobs within an environment context where environment-specific variables and secrets can be retrieved during execution. You should align your GitHub environments with your deployment environments as follows:

- The GitHub environment names should match the [environments](/platform/environments/) subfolder names. For example, an environment `platform/environments/dev` should align to a GitHub environment with the name `dev`. This allows the pipeline to match the GitHub environment with the correct deployment scope and allows for each environment to be deployed using separate identities and subscriptions by configuring environment specific variables for `ARM_CLIENT_ID`, `ARM_SUBSCRIPTION_ID`, and `ARM_TENANT_ID`.
- Any environment names should be added to the `workflow_dispatch.inputs.environment` input choices to ensure it possible to scope deployments to that environment. For example, if you are planning on creating `dev`, `uat`, and `prod` environments, the environment input should be adjusted as follows:

```yaml
on:
  workflow_dispatch:
    inputs:
    # ...
      # The environment deployment scope
      environment:
        default: 'all'
        description: 'Environment:'
        required: true
        type: choice
        options:
          - 'all'
          - 'dev'
          - 'uat'
          - 'prod'
    # ...
```

> [!Note]
> The same is true for the `workflow_dispatch.inputs.regions` and `workflow_dispatch.inputs.stacks` inputs. Each of these should contain a list of choices including `all` and any target region or stack names in order to scope deployments appropriately.

#### Deployment

The `workflow_dispatch` deployment type is manually triggered. Deployment parameters are made available to scope the deployment as follows:

| Parameter | Options | Description | Default |
| --------- | ------- | ----------- | ------- |
| Mode      | `Plan`, `Apply` | Determines whether Terragrunt runs `terraform plan` or `terraform apply` for the target scope. It is recommended to run in `Plan` mode to verify pending changes before running in `Apply` mode. | `Plan` |
| Environment | `all`, `<environment>` | When `all` is selected, the deployment will be scoped to all stacks, in all regions, in all environments.<br><br>When a specific environment is selected, the deployment will be scoped to all stacks, in all regions, in the specific environment. | `all` |
| Region | `all`, `<region>` | Requires an environment to be specified.<br><br>When `all` is selected, the deployment will be scoped to all stacks, in all regions, in the specified environment. <br><br>When a specific region is selected, the deployment will be scoped to all stacks in the specified region, in the specified environment. | `all` |
| Stack | `all`, `<stack>` | Requires an environment and region to be specified. <br><br>When `all` is selected, the deployment will be scoped to all stacks, in the specified region and environment. <br><br>When a specified stack is selected, the deployment will be scoped to the specified stack in the specified region and environment. | `all` |

This approach allows for easily scoping a deployment from a single stack of infrastructure, to a whole region, environment, or cross-environment workload.

> [!Note]
> Setting a specific lower-level scope will not be honoured if a higher-level scope is set to `all`. For example, a deployment scoped to `environment: dev`, `region: all`, `stack: network` will deploy all stacks in all regions in the `dev` environment, as `region` is set to `all` and so overrides the fact that `stack` is set to `network`. Stack-specific multi-region/environment deployments are not yet supported.

### Scaling the Solution

The structure of this repository is designed to offer maximal scalability in terms of deployment scope. The skeletal structure of the [environments](/platform/environments/) directory lends itself well to extension whilst allowing re-use of stacks and modules, keeping the codebase [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

#### Environments

Adding an environment requires creating a new folder under the [environments](/platform/environments/) directory. The environment folder should match the environment name and must contain an `environment.hcl` file with at least an `input` block as follows:

```hcl
inputs = {
  environment = "<name>"
}
```

> [!Note]
>
> - The `inputs` block can be used to define environment-specific input variables. Any environment-specific inputs defined here are merged with any other inputs defined in the `location.hcl` and `terragrunt.hcl` files in the child region and stack folders.

#### Regions

Adding a region requires creating a new folder under the appropriate environment directory. The region folder name should match the Azure region name in CLI format and must contain a `location.hcl` file with at least an `input` block as follows:

```hcl
inputs = {
  location = "<location>"
}
```

> [!Note]
>
> - The `inputs` block can be used to define region-specific input variables. Any region-specific inputs defined here are merged with any other inputs defined in the parent `environment.hcl` file and `terragrunt.hcl` files in the child stack folders.

#### Stacks

Adding a stack to a region requires creating a new folder under the appropriate region directory. The stack folder name should match the stack folder under the main [stacks](/platform/stacks/) directory and must contain a `terragrunt.hcl` file with at least the `include`, `terraform`, and `inputs` blocks as follows:

```hcl
include {
  path = find_in_parent_folders("deployment.hcl")
}

terraform {
  source = "${get_repo_root()}//platform/stacks/<stack>"
}

inputs = {}
```

> [!Note]
>
> - The `include` block references the [root Terragrunt configuration](/platform/environments/deployment.hcl).
> - The `terraform` block references the [stack](/platform/stacks/) being deployed.
> - The `inputs` block can be used to define stack-specific input variables. Consider this equivalent to a `tfvars` file. Any stack-specific inputs defined here are merged with any other inputs defined in the `location.hcl` and `environment.hcl` files in the parent region and environment folders.
> - A `dependency` block is required for stacks which depend on resources deployed in other stacks and offers a way to pass outputs from the dependee stack to the dependent stack. See [stack dependencies](#stack-dependencies).

#### Stack Dependencies

Complex deployments will eventually necessitate dependencies between stacks. Indeed this is often the case when multiple providers are used. For example, a first stack may deploy an AKS cluster using the AzureRM provider, and a second stack may deploy Kubernetes resources into the AKS cluster using the Kubernetes provider which will depend on the AKS cluster having already been created in order to authenticate.

Terragrunt offers a mechanism for passing outputs from one stack (dependee) as the inputs to another stack (dependent) through the use of the `dependency` block. One or more `dependency` blocks may be defined within the `terragrunt.hcl` file for a dependent stack.

Once a dependency is defined, Terragrunt will orchestrate deployments by arranging stacks into deployment groups. Stacks will be deployed one group at a time. Stacks not dependent on each other may form part of the same deployment group and can be deployed in parallel, up to the degree of parallelism specified (`--terragrunt-parallelism`).

##### Dependencies and Mocks

The below `dependency` and `input` block show an example of a stack which has a dependency on an output from another stack in the same environment region:

```hcl
dependency "dev_uksouth_01_example" {
  config_path = "${get_repo_root()}//platform/environments/dev/uksouth/01-example"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    app_service_integration_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    # ...
  }

  inputs = {
    app_service_integration_subnet_id = dependency.dev_uksouth_01_example.virtual_network_subnet_ids["AppServiceIntegrationSubnet"]
    # ...
}
```

The above example also showcases the use of mock values when running `validate` and `plan` commands. This allows plans to succeed based on mock values even in cases where the dependee stack has not yet been applied. During deployment, Terragrunt will orchestrate the deployment such that the dependee stack is deployed prior to the dependent stack, and once deployed will use the real output values from the dependee stack instead of the mock values.

> [!Tip]
> It is recommended to align dependency names to their hierarchy. For example, if the stack depends on the `01-example` stack in the `uksouth` region of the `dev` environment, then the dependency name should be similar to `dev_uksouth_01_example` for clarity.

##### Forced Dependencies

Occasionally, a stack should depend on another stack despite not requiring any inputs from the dependee stack. In these cases a `dependency` block can still be added to allow Terragrunt to produce a stack dependency graph and split stacks into deployment groups. However, note the use of the `skip_outputs` attribute to facilitate this scenario:

```hcl
dependency "dev_uksouth_01_example" {
  config_path  = "${get_repo_root()}//platform/environments/dev/uksouth/01-example"
  skip_outputs = true
}

inputs = {}
```
