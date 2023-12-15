targetScope = 'subscription'

@description('Location to deploy to')
param location string = 'uksouth'

@description('Environment to deploy to')
param env string = 'dev'

@description('Service ID used in resource naming to group all related resources')
param serviceId string

@description('Apim publisher email')
param apimPublisherEmail string

@description('Apim publisher name')
param apimPublisherName string

// variables
var apimResourceGroupName = 'rg-apim-${serviceId}-${env}'
var sharedResourceGroupName = 'rg-shared-${serviceId}-${env}'

resource sharedRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: sharedResourceGroupName
  location: location
}

module kv 'modules/keyvault.bicep' = {
  name: 'kv-mod-${env}'
  scope: sharedRg
  params: {
    location: location
    env: env
    serviceId: serviceId
  }
}

module monitor 'modules/monitor.bicep' = {
  name: 'monitor-mod-${env}'
  scope: sharedRg
  params: {
    location: location
    env: env
    serviceId: serviceId
  }
}

resource apimRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: apimResourceGroupName
  location: location
}

module apim './modules/apim.bicep' = { 
  name: 'apim-mod-${env}'
  scope: apimRg
  params: {
    location: location
    env: env
    serviceId: serviceId
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    appInsightsName: monitor.outputs.appInsightsName
    appInsightsId: monitor.outputs.appInsightsId
    appInsightsInstrumentationKey: monitor.outputs.appInsightsInstrumentationKey
  }
}

resource sbusRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: sharedResourceGroupName
  location: location
}

module sbus 'modules/servicebus.bicep' = {
  scope: sbusRg
  name: 'sbus-mod-${env}'
  params: {
    serviceId: serviceId
    env: env
    location: location
  }
}
