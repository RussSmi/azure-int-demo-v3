targetScope='resourceGroup'

@description('The environment name beong deployed to, e.g. dev, test, prod')
param env string = 'dev'

@description('Service Id to group all resources')
param serviceId string

@description('The name of the service bus namespace')
param serviceBusName string = 'sbus-${serviceId}-${env}'

@description('Location for all resources.')
param location string = resourceGroup().location

resource sbusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  tags: {
    source: 'Bicep'
  }
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}



resource sbusPubTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: sbusNamespace
  name: 'sbtopicPub${serviceId}'
  properties: {
    enablePartitioning: true
  }
}

resource sbusPubTopicSub 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  parent: sbusPubTopic
  name: 'sbsubSub${serviceId}'
}
