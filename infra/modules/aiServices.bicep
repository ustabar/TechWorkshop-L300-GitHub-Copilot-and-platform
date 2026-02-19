@description('Location for the resource')
param location string

@description('Name of the AI Services resource')
param aiServicesName string

@description('SKU for AI Services (F0, S0, etc.)')
param skuName string = 'S0'

@description('Tags for the resource')
param tags object = {}

resource aiServices 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: aiServicesName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: 'CognitiveServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
}

@description('Endpoint of the AI Services resource')
output endpoint string = aiServices.properties.endpoint

@description('Resource ID of the AI Services resource')
output resourceId string = aiServices.id

@description('Name of the AI Services resource')
output name string = aiServices.name
