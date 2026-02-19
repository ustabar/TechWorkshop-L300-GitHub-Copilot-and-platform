@description('Location for the resource')
param location string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('SKU name for App Service Plan (B1, B2, B3, P1V2, etc.)')
param skuName string = 'B1'

@description('Tier for App Service Plan (Basic, Standard, Premium)')
param skuTier string = 'Basic'

@description('Number of worker instances')
param numberOfWorkers int = 1

@description('Tags for the resource')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: skuName
    tier: skuTier
    capacity: numberOfWorkers
  }
  properties: {
    reserved: true
  }
}

@description('Resource ID of the App Service Plan')
output resourceId string = appServicePlan.id

@description('Name of the App Service Plan')
output name string = appServicePlan.name
