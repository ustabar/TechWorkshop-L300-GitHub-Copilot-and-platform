# ZavaStorefront Infrastructure as Code

This directory contains Bicep Infrastructure-as-Code templates for deploying the ZavaStorefront web application to Azure using Azure Developer CLI (AZD).

## Architecture Overview

The infrastructure deploys the following components to **westus3** in a single resource group:

```
Resource Group: rg-zavastore-dev-westus3
├── Azure Container Registry (ACR)
├── App Service Plan (Linux)
├── Web App for Containers
├── Managed Identity (System-assigned)
├── Role Assignment (AcrPull)
├── Application Insights
├── Log Analytics Workspace
└── Azure AI Services (Microsoft Foundry)
```

## Prerequisites

### Local Development

1. **Azure CLI**: Install the latest version
   ```bash
   # Windows with Winget
   winget install Microsoft.AzureCLI
   
   # Or download from https://aka.ms/azure-cli
   ```

2. **Azure Developer CLI (AZD)**: Required for deployment
   ```bash
   # Windows with Winget
   winget install Microsoft.Azure.DeveloperCLI
   
   # Or download from https://aka.ms/azd
   ```

3. **Bicep CLI**: Usually included with Azure CLI
   ```bash
   az bicep install
   ```

4. **Azure Subscription**: With appropriate permissions to create resources
   - Contributor or Owner role on the subscription
   - Sufficient quota for westus3 region

5. **.NET 6.0 SDK**: For local development
   ```bash
   dotnet --version
   ```

### Azure Credentials

Ensure you are logged into Azure:

```bash
az login
az account show
```

## File Structure

```
infra/
├── main.bicep                    # Main orchestrator template
├── params.bicep.json             # Parameter values
└── modules/
    ├── resourceGroup.bicep       # Resource group creation (subscription scope)
    ├── acr.bicep                 # Container Registry
    ├── appServicePlan.bicep      # App Service Plan (Linux)
    ├── webApp.bicep              # Web App for Containers
    ├── managedIdentity.bicep     # User-assigned Managed Identity
    ├── roleAssignment.bicep      # AcrPull role assignment
    ├── appInsights.bicep         # Application Insights + Log Analytics
    └── aiServices.bicep          # Azure AI Services (Foundry)

.github/workflows/
├── acr-build.yml                 # Cloud-based container build (no local Docker)
└── deploy-infrastructure.yml     # Infrastructure deployment workflow

src/
└── Dockerfile                    # Multi-stage build for .NET 6.0 app
```

## Deployment Steps

### Step 1: Clean Up Previous AZD Initialization (if needed)

If you previously initialized AZD and want to start fresh:

```bash
Remove-Item -Path ".\.azure" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\azure.yaml" -Force -ErrorAction SilentlyContinue
```

### Step 2: Initialize AZD Project

```bash
cd C:\Codes\workshops\TechWorkshop-L300-GitHub-Copilot-and-platform
azd init -t ./infra/main.bicep
```

**Response to prompts:**
- Use the current directory
- Select your Azure subscription
- Select location: `westus3`

### Step 3: Configure Azure Credentials

Set required environment variables:

```powershell
# PowerShell
$env:AZURE_SUBSCRIPTION_ID = "your-subscription-id"
$env:AZURE_TENANT_ID = "your-tenant-id"
$env:AZURE_LOCATION = "westus3"

# Or create .env file
Write-Host "AZURE_SUBSCRIPTION_ID=your-subscription-id" | Out-File -FilePath .env
Write-Host "AZURE_LOCATION=westus3" | Out-File -FilePath .env -Append
```

### Step 4: Provision Infrastructure

Provision all resources using Bicep templates:

```bash
azd provision --no-prompt
```

**What this does:**
- Creates resource group (`rg-zavastore-dev-westus3`)
- Deploys Container Registry (ACR)
- Creates App Service Plan and Web App
- Sets up Managed Identity with AcrPull permissions
- Deploys Application Insights and Log Analytics
- Provisions Azure AI Services (Microsoft Foundry)

**Output:**
```
✓ Resource group created
✓ ACR Login Server: zavastoredevacr.azurecr.io
✓ Web App Hostname: web-zavastore-dev.azurewebsites.net
✓ Application Insights Key: [instrumentation-key]
✓ AI Services Endpoint: [endpoint-url]
```

### Step 5: Build and Push Container Image

#### Option A: Using GitHub Actions (Recommended - No Local Docker)

Push to the `dev` branch to trigger the workflow:

```bash
git add .
git commit -m "chore: infrastructure setup"
git push origin dev
```

The workflow `acr-build.yml` will:
- Build the .NET application
- Create a Docker image
- Push to ACR
- No local Docker daemon required

#### Option B: Manual ACR Build (Cloud-based)

```bash
az acr build \
  --registry zavastoredevacr \
  --image zavastore:latest \
  --file ./src/Dockerfile \
  ./src
```

#### Option C: Local Docker Build

If you have Docker installed locally:

```bash
# Build image
docker build -f ./src/Dockerfile -t zavastoredevacr.azurecr.io/zavastore:latest ./src

# Log in to ACR
az acr login --name zavastoredevacr

# Push image
docker push zavastoredevacr.azurecr.io/zavastore:latest
```

### Step 6: Deploy Application

```bash
azd deploy --no-prompt
```

This will:
- Deploy the image from ACR to the Web App
- Configure environment variables
- Update Application Insights settings

### Step 7: Verify Deployment

```bash
# Check web app status
az webapp show --name web-zavastore-dev --resource-group rg-zavastore-dev-westus3

# Get web app URL
az webapp show --name web-zavastore-dev \
  --resource-group rg-zavastore-dev-westus3 \
  --query defaultHostName -o tsv
```

Visit the URL to verify the application is running.

## Security Features

✅ **No Password Authentication**: Uses Azure RBAC with Managed Identity
✅ **AcrPull Role**: App Service pulls images using managed identity (least privilege)
✅ **Network Security**: Public network access can be restricted via firewall rules
✅ **Monitoring**: Application Insights tracks all requests and errors
✅ **Encryption**: HTTPS enforced on Web App

## Managed Identity & RBAC

The infrastructure uses a **User-assigned Managed Identity** with **AcrPull** role on ACR:

```bicep
// Identity principal
managedIdentityPrincipalId: [service-principal-id]

// Role assignment
roleId: 7f951dda-4ed3-4680-a7ca-c893fe7e08d9  // AcrPull
scope: ACR Resource
```

## Customization

### Change Environment Name

Edit `azure.yaml`:
```yaml
name: ZavaStorefront
environment: prod  # Change from dev to prod
location: westus3
```

Or pass parameters to `azd provision`:
```bash
azd provision --parameters environment=prod
```

### Change VM/Container SKUs

Edit `infra/params.bicep.json`:
```json
{
  "appServiceSkuName": { "value": "B2" },  // Change from B1
  "acrSku": { "value": "Standard" },        // Change from Basic
  "aiServicesSku": { "value": "S1" }        // Change from S0
}
```

### Add Custom Parameters

1. Add parameter to `infra/main.bicep`
2. Add default value to `infra/params.bicep.json`
3. Reference in modules

## Cost Optimization

**Estimated Monthly Cost (dev)**: ~$50-75 USD

| Service | SKU | Est. Cost |
|---------|-----|-----------|
| App Service Plan | B1 | $13.14 |
| Container Registry | Basic | $5.00 |
| Application Insights | Standard | $2.00 per GB ingested |
| AI Services | S0 | varies (0.0001 per call) |
| Log Analytics | Pay-as-you-go | ~$2-5 per GB |

**Cost Reduction Tips:**
- Use `B1` or lower tier for dev
- Use `Free` tier for AI Services (if available)
- Delete resources when not in use
- Set Log Analytics retention to 7 days for dev

## Troubleshooting

### Issue: "ResourceGroup scope not valid"
**Solution**: Ensure `main.bicep` uses `targetScope = 'subscription'` at the top.

### Issue: "Managed Identity role assignment fails"
**Solution**: Verify the managed identity is created before role assignment. Check order in `main.bicep`.

### Issue: "Web App can't pull from ACR"
**Solution**: 
- Verify managed identity is assigned to Web App
- Check AcrPull role is assigned to the managed identity
- Verify container image exists in ACR

### Issue: "ACR build fails"
**Solution**:
- Verify Dockerfile path is correct
- Check ACR has `Microsoft.Authorization/roleAssignments/write` permissions
- Ensure GitHub Actions has valid `AZURE_CREDENTIALS`

### Issue: "azd provision timeout"
**Solution**:
- Increase timeout: `azd provision --no-prompt --timeout 600`
- Check Azure CLI is authenticated: `az account show`
- Verify subscription quota for westus3

## Clean Up

### Delete All Resources

```bash
# Option 1: Using AZD
azd down

# Option 2: Using Azure CLI
az group delete --name rg-zavastore-dev-westus3 --yes

# Option 3: Using Azure Portal
# Navigate to resource groups and delete manually
```

### Remove AZD Configuration

```powershell
Remove-Item -Path ".\.azure" -Recurse -Force
Remove-Item -Path ".\azure.yaml" -Force
```

## GitHub Actions Workflows

### ACR Build Workflow (`acr-build.yml`)

**Trigger**: Push to `dev` or `main` branches, or workflow dispatch
**Steps**:
1. Checkout code
2. Azure login (using `AZURE_CREDENTIALS` secret)
3. Build and push to ACR using `az acr build`
4. Logout

**Secrets Required**:
- `AZURE_CREDENTIALS`: JSON with service principal credentials

### Deploy Infrastructure Workflow (`deploy-infrastructure.yml`)

**Trigger**: Manual workflow dispatch
**Steps**:
1. Checkout code
2. Azure login
3. Install AZD
4. Run `azd provision`
5. Run `azd deploy`

**Secrets Required**:
- `AZURE_CREDENTIALS`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

## GitHub Secrets Setup

To use GitHub Actions, add these secrets to your repository:

```bash
# Get credentials
az ad sp create-for-rbac --name "github-actions" \
  --role "Contributor" \
  --scopes /subscriptions/{subscription-id}

# Add to GitHub:
# AZURE_CREDENTIALS: [JSON output from above]
# AZURE_SUBSCRIPTION_ID: your-subscription-id
# AZURE_TENANT_ID: your-tenant-id
```

## References

- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Managed Identities for Azure Resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Web App for Containers](https://learn.microsoft.com/en-us/azure/app-service/containers/)

## Support

For issues or questions:
1. Check the **Troubleshooting** section above
2. Review Azure CLI output for error messages
3. Check GitHub Actions logs for workflow issues
4. Create a GitHub issue with details and logs
