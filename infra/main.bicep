targetScope = 'subscription'

@description('Deployment location')
param location string = 'westus3'

@description('Environment name (dev, prod, etc.)')
param environment string = 'dev'

@description('Resource name prefix')
param namePrefix string = 'zavastore'

@description('User assigned managed identity name')
param managedIdentityName string = '${namePrefix}-${environment}-mi'

@description('Container Registry name')
param acrName string = '${namePrefix}acr${uniqueString(subscription().id)}'

@description('App Service Plan name')
param appServicePlanName string = 'asp-${namePrefix}-${environment}'

@description('Web App name')
param webAppName string = 'web-${namePrefix}-${environment}'

@description('Log Analytics Workspace name')
param logAnalyticsWorkspaceName string = 'law-${namePrefix}-${environment}'

@description('Application Insights name')
param appInsightsName string = 'ai-${namePrefix}-${environment}'

@description('AI Services name')
param aiServicesName string = 'ais-${namePrefix}-${environment}'

@description('Resource Group name')
param resourceGroupName string = 'rg-${namePrefix}-${environment}-${location}'

@description('SKU for Container Registry')
param acrSku string = 'Premium'

@description('SKU for App Service Plan')
param appServiceSkuName string = 'B1'

@description('SKU Tier for App Service Plan')
param appServiceSkuTier string = 'Basic'

@description('Container image name')
param containerImage string = 'zavastore:latest'

@description('SKU for AI Services')
param aiServicesSku string = 'S0'

@description('Tags for all resources')
param tags object = {
  project: 'ZavaStorefront'
  environment: environment
  source: 'bicep'
}

// Module 1: Create Resource Group at subscription scope
module rg './modules/resourceGroup.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    location: location
    resourceGroupName: resourceGroupName
    environment: environment
    tags: tags
  }
}

// Module 2: Create Managed Identity
module managedIdentity './modules/managedIdentity.bicep' = {
  name: 'managedIdentityDeployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    managedIdentityName: managedIdentityName
    tags: tags
  }
  dependsOn: [rg]
}

// Module 3: Create Container Registry
module acr './modules/acr.bicep' = {
  name: 'acrDeployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    acrName: acrName
    skuName: acrSku
    tags: tags
  }
  dependsOn: [rg]
}

// Module 4: Create App Service Plan
module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuName: appServiceSkuName
    skuTier: appServiceSkuTier
    tags: tags
  }
  dependsOn: [rg]
}

// Module 5: Create Log Analytics Workspace & Application Insights
module appInsights './modules/appInsights.bicep' = {
  name: 'appInsightsDeployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
    tags: tags
  }
  dependsOn: [rg]
}

// Module 6: Create Web App
module webApp './modules/webApp.bicep' = {
  name: 'webAppDeployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    webAppName: webAppName
    appServicePlanId: appServicePlan.outputs.resourceId
    acrLoginServer: acr.outputs.loginServer
    containerImage: containerImage
    managedIdentityId: managedIdentity.outputs.resourceId
    acrAdminUsername: acr.outputs.adminUsername
    acrAdminPassword: acr.outputs.adminPassword
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    appInsightsConnectionString: appInsights.outputs.connectionString
    tags: tags
  }
}

// Module 7: Assign AcrPull role to Managed Identity on ACR
// Note: Using admin credentials on ACR for now instead of RBAC
// TODO: Uncomment and fix role assignment for production use
// module roleAssignment './modules/roleAssignment.bicep' = {
//   name: 'roleAssignmentDeployment'
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     principalId: managedIdentity.outputs.principalId
//     acrResourceId: acr.outputs.resourceId
//     roleId: '7f951dda-4ed3-4680-a7ca-c893fe7e08d9' // AcrPull role
//   }
// }

// Module 8: Create AI Services (Microsoft Foundry)
module aiServices './modules/aiServices.bicep' = {
  name: 'aiServicesDeployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    aiServicesName: aiServicesName
    skuName: aiServicesSku
    tags: tags
  }
  dependsOn: [rg]
}

// Outputs
@description('Resource Group ID')
output resourceGroupId string = rg.outputs.resourceGroupId

@description('Resource Group Name')
output resourceGroupName string = rg.outputs.resourceGroupName

@description('ACR Login Server')
output acrLoginServer string = acr.outputs.loginServer

@description('Web App Hostname')
output webAppHostname string = webApp.outputs.hostname

@description('Application Insights Instrumentation Key')
output appInsightsKey string = appInsights.outputs.instrumentationKey

@description('AI Services Endpoint')
output aiServicesEndpoint string = aiServices.outputs.endpoint

@description('Managed Identity Client ID')
output managedIdentityClientId string = managedIdentity.outputs.clientId
