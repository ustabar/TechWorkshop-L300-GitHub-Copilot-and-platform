@description('Location for the resource')
param location string

@description('Name of the Container Registry')
param acrName string

@description('SKU for Container Registry (Basic, Standard, Premium)')
param skuName string = 'Basic'

@description('Tags for the resource')
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
    }
  }
}

@description('Login server URL of the container registry')
output loginServer string = containerRegistry.properties.loginServer

@description('Resource ID of the container registry')
output resourceId string = containerRegistry.id

@description('Name of the container registry')
output name string = containerRegistry.name

@description('Username for admin access')
output adminUsername string = containerRegistry.listCredentials().username

@description('Admin password for container registry')
output adminPassword string = containerRegistry.listCredentials().passwords[0].value
