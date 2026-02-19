@description('Location for the resource')
param location string

@description('Name of the Web App')
param webAppName string

@description('App Service Plan Resource ID')
param appServicePlanId string

@description('Container Registry login server')
param acrLoginServer string

@description('Container image name (e.g., zavastore:latest)')
param containerImage string = 'zavastore:latest'

@description('Managed Identity Resource ID')
param managedIdentityId string

@description('ACR Admin Username')
param acrAdminUsername string

@description('ACR Admin Password')
@secure()
param acrAdminPassword string

@description('Application Insights Instrumentation Key')
param appInsightsInstrumentationKey string

@description('Application Insights Connection String')
param appInsightsConnectionString string

@description('Tags for the resource')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  tags: union(tags, {
    'azd-service-name': 'webapp'
  })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${containerImage}'
      alwaysOn: true
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrAdminUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrAdminPassword
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATION_KEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
      ]
      connectionStrings: [
        {
          name: 'DefaultConnection'
          connectionString: appInsightsConnectionString
          type: 'Custom'
        }
      ]
    }
  }
}

@description('Default hostname of the web app')
output hostname string = webApp.properties.defaultHostName

@description('Resource ID of the web app')
output resourceId string = webApp.id
