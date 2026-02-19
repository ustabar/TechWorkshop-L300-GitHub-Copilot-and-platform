# GitHub Actions Deployment Workflow

This workflow builds and deploys the ZavaStorefront application to Azure App Service.

## Required GitHub Secrets

Configure the following secrets in your GitHub repository settings:

| Secret | Description | Example |
|--------|-------------|---------|
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure tenant/directory ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_ID` | Service principal client ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `ACR_NAME` | Azure Container Registry name | `zavastoreacrgs7ampc7v7p7s` |
| `ACR_USERNAME` | ACR username | From ACR admin credentials |
| `ACR_PASSWORD` | ACR password | From ACR admin credentials |
| `AZURE_APP_NAME` | App Service name | `web-zavastore-dev` |
| `AZURE_RESOURCE_GROUP` | Resource group name | `rg-zavastore-dev-westus3` |

## Setting Up Secrets

### Using Azure CLI to get credentials:

```bash
# Get subscription ID
az account show --query id -o tsv

# Get tenant ID
az account show --query tenantId -o tsv

# Get ACR credentials
az acr credential show --resource-group <RESOURCE_GROUP> --name <ACR_NAME>

# Get App Service name and resource group from your deployment
```

### To find your service principal credentials:

If using OIDC authentication, create a service principal:

```bash
az ad sp create-for-rbac --name "GitHub-Actions" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
```

Then add the returned client ID and tenant ID to GitHub secrets.

### Then add all secrets to GitHub:

1. Go to your repository Settings → Secrets and variables → Actions
2. Click "New repository secret" for each secret above
3. Paste the values from your Azure resources
