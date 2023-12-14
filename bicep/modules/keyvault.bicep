targetScope='resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The environment name beong deployed to, e.g. dev, test, prod')
param env string = 'dev'

@description('Service Id to group all resources')
param serviceId string

var keyVaultName = 'kv-${serviceId}${env}${uniqueString(resourceGroup().id)}'

resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
    accessPolicies: [
      // {
      //   tenantId: 'string'
      //   objectId: 'string'
      //   applicationId: 'string'
      //   permissions: {
      //     keys: [
      //       'string'
      //     ]
      //     secrets: [
      //       'string'
      //     ]
      //     certificates: [
      //       'string'
      //     ]
      //     storage: [
      //       'string'
      //     ]
      //   }
      // }
    ]
  }
}

output keyVaultName string = key_vault.name
