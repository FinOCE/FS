// Parameters
@description('The environment to build in')
@allowed([ 'dev', 'prod' ])
param environment string

@description('The location to deploy to')
@allowed([ 'eastus' ])
param location string

// Names
var suffix = '-fs-${environment}'

var webPubSub = 'wps${suffix}'
var cosmosDb = 'cdb${suffix}'
var storageAccount = uniqueString(resourceGroup().id)
var serverFarm = 'sf${suffix}'
var applicationInsights = 'ai${suffix}'
var functionApp = 'fa${suffix}'

// Create web pub sub
resource azWebPubSub 'Microsoft.SignalRService/webPubSub@2021-10-01' = {
  name: webPubSub
  location: location
  sku: {
    capacity: 1 // 1, 2, 5, 10, 20, 50, 100
    name: 'Free_F1' // 'Free_F1', 'Standard_S1'
    tier: 'Free' // 'Free', 'Standard'
  }
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Create cosmos db
resource azCosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDb
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

// Create storage account
resource azStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccount
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
  }
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${azStorageAccount.listKeys().keys[0].value}'

// Create server farm
resource azServerFarm 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: serverFarm
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

// Create application insights
resource azApplicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsights
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// Create function app
resource azFunctionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionApp
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: azServerFarm.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageAccountConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionApp
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: azApplicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'DbConnectionString'
          value: azCosmosDb.listConnectionStrings().connectionStrings[0].connectionString
        }
      ]
    }
  }
}

// Create database containers
module database 'database.bicep' = {
  name: 'database.bicep'
  params: {
    cosmosDbName: azCosmosDb.name
  }
}

// Outputs
output functionAppName string = azFunctionApp.name
