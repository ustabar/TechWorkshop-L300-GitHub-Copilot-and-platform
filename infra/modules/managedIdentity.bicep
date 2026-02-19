@description('Location for the resource')
param location string

@description('Name of the Managed Identity')
param managedIdentityName string

@description('Tags for the resource')
param tags object = {}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: managedIdentityName
  location: location
  tags: tags
}

@description('Resource ID of the managed identity')
output resourceId string = managedIdentity.id

@description('Principal ID of the managed identity')
output principalId string = managedIdentity.properties.principalId

@description('Client ID of the managed identity')
output clientId string = managedIdentity.properties.clientId

@description('Name of the managed identity')
output name string = managedIdentity.name
