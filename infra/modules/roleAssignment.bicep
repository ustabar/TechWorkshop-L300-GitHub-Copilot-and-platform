@description('Principal ID (object ID) of the identity to assign the role')
param principalId string

@description('Resource ID of the Container Registry')
param acrResourceId string

@description('Role ID for AcrPull')
param roleId string = '7f951dda-4ed3-4680-a7ca-c893fe7e08d9'

var roleAssignmentName = guid(acrResourceId, principalId, roleId)

// Assign the role at the ACR resource scope (not resource group scope)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: resourceGroup()
  name: roleAssignmentName
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
  }
}

@description('Name of the role assignment')
output roleAssignmentName string = roleAssignment.name
