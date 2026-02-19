# GitHub Actions Deployment Workflow

This workflow builds and deploys the ZavaStorefront application to Azure App Service.

## Required GitHub Secrets

Configure the following secret in your GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | JSON formatted Azure service principal credentials |
| `ACR_NAME` | Azure Container Registry name |
| `ACR_USERNAME` | ACR username |
| `ACR_PASSWORD` | ACR password |
| `AZURE_APP_NAME` | App Service name |
| `AZURE_RESOURCE_GROUP` | Resource group name |

## Setting Up Secrets

### Step 1: Create a Service Principal

```bash
az ad sp create-for-rbac \
  --name "GitHub-Actions" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --json-auth
```

This command outputs JSON like:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "...",
  ...
}
```

### Step 2: Add the AZURE_CREDENTIALS secret

1. Go to GitHub repo → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `AZURE_CREDENTIALS`
4. Value: **Paste the entire JSON output** from the command above
5. Click "Add secret"

### Step 3: Get ACR credentials

```bash
az acr credential show \
  --resource-group <RESOURCE_GROUP> \
  --name <ACR_NAME>
```

Add these secrets:
- `ACR_NAME`: Your registry name
- `ACR_USERNAME`: Username from credential show output
- `ACR_PASSWORD`: Password from credential show output

### Step 4: Add Azure resource names

Get your App Service and Resource Group names:

```bash
# List App Services
az webapp list --query "[].{name:name, resourceGroup:resourceGroup}"
```

Add these secrets:
- `AZURE_APP_NAME`: Your web app name
- `AZURE_RESOURCE_GROUP`: Your resource group name
