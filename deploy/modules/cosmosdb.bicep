  
@description('Cosmos DB account name')
param accountName string

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the Core (MongoDB) database')
param databaseName string

@description('The name for the collection')
param collectionName string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: toLower(accountName)
  location: location
  properties: {
    // enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
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

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  name: '${toLower(databaseName)}'
  parent: cosmosAccount
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource collection 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  name: '${toLower(collectionName)}'
  parent: cosmosDB
  properties: {
    resource: {
      id: collectionName
    }
	partitionKey: {
		kind: 'Hash'
		paths: [
			'/_partitionKey'
		]
	}
  }
}

output cosmosDBAccountName string = cosmosAccount.name
