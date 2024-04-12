# Terragrunt Deployment Template

This repository provides an example structure for using Terragrunt to orchestrate multiple Terraform deployments in a way that increases the scalability of Terraform whilst minimising the increase in management overhead.

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

> [!Tip]
> Local modules are not necessary for cases where you are using modules from a registry, such as the [Terraform public registry](https://registry.terraform.io/).

Modules should have the following characteristics:

- Environment-agnostic and location-agnostic.
- Deploy a specific resource, and any supporting resources, in a best-practice configuration by default.
- Designed for re-use across stacks by providing appropriate variables to offer a reasonable degree of customisation.

For example, an app service plan module might configure zone-redundancy and multiple instances by default but offer variables to downgrade or disable this behaviour for workloads where this is not required.

### Stacks

The [stacks](/platform/stacks/) directory contains one or more subdirectories of Terraform deployments (stacks).

> [!Tip]
> It is recommended to prefix stacks with a number to highlight the deployment/dependency order between stacks.

Stacks should have the following characteristics:

- Environment-agnostic and location-agnostic.
- Deploy one or more modules (each containing one or more resources), in a best-practice configuration by default.
- Designed for re-use across environments by providing appropriate variables to offer a reasonable degree of customisation.

For example, a stack which deploys a virtual network should "pass-through" the variable for configuring the virtual network address space from the virtual network module to the stack variables such that the address space may be configured differently per-environment.

### Environments

The [environments](/platform/environments/) directory contains one or more subdirectories representing deployment environments (e.g. `dev`, `prod`). A `deployment.hcl` file contains the root-level Terragrunt configuration. This includes a reference to the shared remote state configuration and merging of environment-level and region-level variables. Variable inputs which should be applied globally may be defined here.

Each environment subdirectory contains one or more subdirectories representing deployment locations (e.g. `uksouth`, `ukwest`). A `environment.hcl` file contains the environment-level Terragrunt configuration. Variable inputs which should be applied to all stacks in the environment may be defined here.

Each location subdirectory contains one or more subdirectories of Terraform deployments (stacks). A `location.hcl` contains the region-level Terragrunt configuration. Variable inputs which should be applied to all stacks in the region may be defined here.

Each stack subdirectory contains a `terragrunt.hcl` file with the stack-level configuration. This includes a reference to the stack directory being deployed, as well as any dependencies on stacks, whether they be in the same environment and region or other environments and regions. Variable inputs specific to the stack may be defined here.

## Usage

The below sections describe how to use this deployment methodology either manually or through GitHub Actions, allowing you to scope your deployments appropriately.

> [!Note]
> Before running deployments, please see the [platform](/platform/) documentation for guidance on pre-requisite setup including creating a managed identity for deployments, a storage account for shared state, and initial Terragrunt configuration.

### Scoped Deployments

#### Stack Deployment

#### Region Deployment

#### Environment Deployment

#### Full Deployment

### Deployment Pipeline
