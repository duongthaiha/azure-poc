param primaryLocation string 
param secondaryLocation string 
param cosmosDBName string


resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: cosmosDBName
  location: primaryLocation
  kind: 'GlobalDocumentDB'
  properties: {
    locations: [
      {
        locationName: primaryLocation
        failoverPriority: 0
        isZoneRedundant: false
      }
      {
        locationName: secondaryLocation
        failoverPriority: 1
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}
output cosmosId string = cosmosDB.id
