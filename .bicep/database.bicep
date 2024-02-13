// Parameters
@description('The database account name')
param cosmosDbName string

// Get cosmos db account
resource azCosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosDbName
}

// TODO: Create databases/containers as done below (copied from blaze, can delete these comments once one is implemented)

// // Create links-db database
// resource azCosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
//   parent: azCosmosDb
//   name: 'links-db'
//   properties: {
//     resource: {
//       id: 'links-db'
//     }
//   }
// }

// // Create links container
// resource azCosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
//   parent: azCosmosDbDatabase
//   name: 'links'
//   properties: {
//     resource: {
//       id: 'links'
//       partitionKey: {
//         paths: ['/id']
//         kind: 'Hash'
//       }
//     }
//   }
// }
