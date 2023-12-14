targetScope='resourceGroup'

@description('The environment name beong deployed to, e.g. dev, test, prod')
param env string = 'dev'

@description('Service Id to group all resources')
param serviceId string

@description('The name of the API Management service instance')
param apiManagementServiceName string = 'apim-${serviceId}-${env}'

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the app insights resource')
param appInsightsName string

@description('The app insights id')
param appInsightsId string

@description('The app insights instrumentation key')
param appInsightsInstrumentationKey string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apimName_appInsightsLogger_resource 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = {
  parent: apiManagementService
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource apimName_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2023-03-01-preview' = {
  parent: apiManagementService
  name: 'applicationinsights'
  properties: {
    loggerId: apimName_appInsightsLogger_resource.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
  }
}
