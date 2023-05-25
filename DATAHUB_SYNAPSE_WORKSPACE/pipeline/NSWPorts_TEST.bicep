param rgName string = 'nswp-aeast-rg-datalake'
param location string = 'australiaeast'
param storageAccountName string = 'nswpaeasthottst01'
param synapseWorkspaceName string = 'nswpaesynapsetst01'
param synapseAdminLogin string = 'sqladminuser'
param synapseAdminPassword string = 'P@ssw0rd9!'
param sqlPoolName string = 'nswpaesynapsetst01'
param sqlPoolAutoPauseDelay int = 60
param sqlPoolAutoPauseEnabled bool = true
param sqlPoolAutoScaleEnabled bool = true
param sqlPoolAutoScaleMinCapacity int = 3
param sqlPoolAutoScaleMaxCapacity int = 200
param sqlPoolCapacity int = 3
param sqlPoolSkuName string = 'Serverless'
param sparkPoolName string = 'synapse-spark'
param workspaceCollation string = 'Latin1_General_CI_AS'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {}
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedPrivateEndpointSettings: {
      managedPrivateEndpoints: []
      privateLinkConfigurations: []
    }
    storageAccountDetails: {
      storageAccountResourceId: storage.id
    }
    sqlAdministratorLogin: synapseAdminLogin
    sqlAdministratorLoginPassword: synapseAdminPassword
    sqlManagedPrivateEndpointSettings: {
      enablePrivateEndpointConnection: true
    }
    workspaceProvisioningState: 'Succeeded'
    bigDataPoolOffers: [
      {
        name: 'default'
        properties: {
          defaultSparkPoolName: sparkPoolName
        }
      }
    ]
    managedPrivateEndpoints: []
    privateLinkConfigurations: []
    sqlPoolDefaultSensitivityLabel: {
      labelName: ''
      labelId: ''
      informationType: ''
    }
    sqlPools: [
      {
        name: sqlPoolName
        properties: {
          autoPause: {
            delayInMinutes: sqlPoolAutoPauseDelay
            enabled: sqlPoolAutoPauseEnabled
          }
          autoScale: {
            enabled: sqlPoolAutoScaleEnabled
            maxCapacity: sqlPoolAutoScaleMaxCapacity
            minCapacity: sqlPoolAutoScaleMinCapacity
          }
          capacity: sqlPoolCapacity
          sku: {
            name: sqlPoolSkuName
          }
        }
      }
    ]
    collation: workspaceCollation
    firewallSettings: {
      allowAzureServices: false
      ipRules: []
    }
  }
  dependsOn: [
    storage
  ]
}
