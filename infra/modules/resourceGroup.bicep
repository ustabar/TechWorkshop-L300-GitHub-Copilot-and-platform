targetScope = 'subscription'

@description('Location for all resources')
param location string

@description('Name of the resource group')
param resourceGroupName string

@description('Environment name (dev, prod, etc.)')
param environment string

@description('Tags for resource group')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: union(tags, {
    environment: environment
  })
}

@description('Resource group ID')
output resourceGroupId string = resourceGroup.id

@description('Resource group name')
output resourceGroupName string = resourceGroup.name
