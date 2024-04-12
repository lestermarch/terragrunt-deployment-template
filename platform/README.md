# Platform

This directory contains everything required for [platform deployment](/.github/workflows/platform-deployment.yaml). The below section details deployment pre-requisites.

## Pre-Requisites

The following sections walk through the pre-requisite steps required to prepare for deployments.

- [1. GitHub Environment](#1-github-environment)
  - [1.1. Variables](#11-variables)
  - [1.2. Environments](#12-environments)
- [2. Shared Azure Environment](#2-shared-azure-environment)
  - [2.1. Variables](#21-variables)
  - [2.2. Resource Group](#22-resource-group)
  - [2.3. Managed Identity](#23-managed-identity)
  - [2.4. Storage Account](#24-storage-account)
  - [2.5. Identity Permissions & Federation](#25-identity-permissions--federation)
- [3. Configure Remote Backend](#3-configure-remote-backend)
  - [3.1. Generate Remote Backend Configuration](#31-generate-remote-backend-configuration)
  - [3.2. Create GitHub Environment Variables](#32-create-github-actions-variables)

> [!Note]
> The variables set during setup steps may be referenced by later steps. Take care to ensure these are not lost of overwritten during deployment.

### 1. GitHub Environment

To facilitate deployments a GitHub repo should be created. Later, an Azure user-assigned managed identity will be federate with GitHub to allow the use of OAuth for authentication to Azure resources.

#### 1.1. Variables

```bash
# Modify as required:
GITHUB_ENVIRONMENT_NAME="<environmentName>"
GITHUB_ORGANIZATION_NAME="<orgName>"
GITHUB_REPOSITORY_NAME="<repoName>"
```

#### 1.2. Environments

Create an environment matching the value of `$GITHUB_ENVIRONMENT_NAME` in your GitHub repository.

> [!Note]
> At the time of writing the GitHub CLI [does not support](https://github.com/cli/cli/issues/5149) creation of environments, so this step must be performed manually.

### 2. Shared Azure Environment

An Azure subscription should be used to host shared resources used for deployments across environments. The following steps deploy resources into the chose shared subscription. Make sure you are scoped to the correct subscription with `az account set -s <subscriptionId>` and `az account show`.

#### 2.1. Variables

Set some variables:

```bash
# Modify as required:
DEPLOYMENT_IDENTITY_NAME="<managedIdentityName>"
LOCATION="<region>"
RESOURCE_GROUP_NAME="<resourceGroupName>"
SHARED_SUBSCRIPTION_ID="<sharedSubscriptionId>"

# Do not modify:
RESOURCE_GROUP_ID=$(az group show --name $RESOURCE_GROUP_NAME --query id -o tsv)
ENTROPY=$(echo $RESOURCE_GROUP_ID | sha256sum | cut -c1-8)
STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_PREFIX$ENTROPY"
STORAGE_CONTAINER_NAME="${GITHUB_REPOSITORY_NAME,,}"
```

#### 2.2. Resource Group

Create an Azure resource group for the deployment resources:

```bash
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION
```

#### 2.3. Managed Identity

Create a user-assigned managed identity for deployment:

```bash
az identity create \
  --name $DEPLOYMENT_IDENTITY_NAME \
  --resource-group-name $RESOURCE_GROUP_NAME
```

> [!Note]
> This example creates a single deployment identity for simplicity. However, it is recommended to create separate user-assigned managed identities for each environment.

#### 2.4. Storage Account

Create a storage account to store Terraform state files:

```bash
DEPLOYMENT_IDENTITY_ID=$(az identity show --name $DEPLOYMENT_IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query id -o tsv)

az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --identity-type "UserAssigned" \
  --user-assigned-identity-id $DEPLOYMENT_IDENTITY_ID \
  --sku "Standard_RAGZRS" \
  --min-tls-version "TLS1_2" \
  --allow-blob-public-access false
```

Create a storage container for the deployment repository:

```bash
az storage container create \
  --name $STORAGE_CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --auth-mode "login"
```

#### 2.5. Identity Permissions & Federation

Assign the required deployment permissions to the managed identity:

```bash
DEPLOYMENT_IDENTITY_PRINCIPAL_ID=$(az identity show --name $DEPLOYMENT_IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query principalId -o tsv)

az role assignment create \
  --assignee-object-id $DEPLOYMENT_IDENTITY_PRINCIPAL_ID \
  --assignee-principal-type "ServicePrincipal" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

az role assignment create \
  --assignee-object-id $DEPLOYMENT_IDENTITY_PRINCIPAL_ID \
  --assignee-principal-type "ServicePrincipal" \
  --role "User Access Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

> [!Note]
> This example assigns the `Contributor` and `User Access Administrator` roles to a target subscription `$SUBSCRIPTION_ID`. Adjust the permissions and scope as required for deployments.

Federate the identity to GitHub to enable use of OAuth:

```bash
az identity federated-credential create \
  --name $GITHUB_REPOSITORY_NAME \
  --identity-name $DEPLOYMENT_IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --audiences "api://AzureADTokenExchange" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:$GITHUB_ORGANIZATION_NAME/$GITHUB_REPOSITORY_NAME:environment:$GITHUB_ENVIRONMENT_NAME"
```

### 3. Configure Remote Backend

In this section you configure Terragrunt to use the Azure storage account as a remote backend for Terraform state, and configure the required environment variables within the GitHub deployment environment.

#### 3.1. Generate Remote Backend Configuration

Replace the placeholder content in the [root Terragrunt configuration](/platform/environments/deployment.hcl) for remote backend:

```bash
sed -i -e 's/{{stateSubscriptionId}}/'"$SHARED_SUBSCRIPTION_ID"'/g' \
       -e 's/{{stateResourceGroupName}}/'"$RESOURCE_GROUP_NAME"'/g' \
       -e 's/{{stateStorageAccountName}}/'"$STORAGE_ACCOUNT_NAME"'/g' \
       -e 's/{{stateContainerName}}/'"$STORAGE_CONTAINER_NAME"'/g' platform/environments/deployment.hcl
```

#### 3.2. Create GitHub Actions Variables

Configure environment variables for the GitHub environment for authentication:

```bash
gh variable set ARM_CLIENT_ID --env $GITHUB_ENVIRONMENT_NAME --body $(az identity show --name $DEPLOYMENT_IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query clientId -o tsv)
gh variable set ARM_SUBSCRIPTION_ID --env $GITHUB_ENVIRONMENT_NAME --body $(az identity show --name $DEPLOYMENT_IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query subscriptionId -o tsv)
gh variable set ARM_TENANT_ID --env $GITHUB_ENVIRONMENT_NAME --body $(az identity show --name $DEPLOYMENT_IDENTITY_NAME --resource-group $RESOURCE_GROUP_NAME --query tenantId -o tsv)
```
