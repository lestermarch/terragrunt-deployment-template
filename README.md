# Terragrunt Deployment Template

This repository provides an example structure for using [Terragrunt](https://terragrunt.gruntwork.io/) to orchestrate multiple Terraform deployments in a way that increases the scalability of Terraform whilst minimising the increase in management overhead.

> [!Note]
> This repository is designed for deployments to Microsoft Azure, but may be adapated for use with other public or private cloud providers.

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

### Manual Scoped Deployments

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

This approach allows for easily scoping a deployment from either a single stack of infrastructure, to a whole region, environment, or cross-environment workload.

> [!Note]
> Setting a specific lower-level scope will not be honoured if a higher-level scope is set to `all`. For example, a deployment scoped to `environment: dev`, `region: all`, `stack: network` will deploy all stacks in all regions in the `dev` environment, as `region` is set to `all` and so overrides the fact that `stack` is set to `network`. Stack-specific multi-region/environment deployments are not yet supported.
