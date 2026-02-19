@description('Location for the resources')
param location string

@description('Name of the Log Analytics Workspace')
param logAnalyticsWorkspaceName string

@description('Name of the Application Insights resource')
param appInsightsName string

@description('SKU for Log Analytics Workspace (PerGB2018, Premium, Standard, etc.)')
param logAnalyticsSkuName string = 'PerGB2018'

@description('Tags for the resources')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsSkuName
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

@description('Instrumentation Key of Application Insights')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('Connection String of Application Insights')
output connectionString string = appInsights.properties.ConnectionString

@description('Resource ID of Log Analytics Workspace')
output logAnalyticsResourceId string = logAnalyticsWorkspace.id

@description('Resource ID of Application Insights')
output appInsightsResourceId string = appInsights.id
