param primaryLocation string = resourceGroup().location
param secondaryLocation string = 'ukwest'
var locations = listLocations(subscription().subscriptionId, '2020-01-01').value
var primaryLocationIndex = indexOf(locations, primaryLocation)

// Cosmos DB account name must be between 3 and 31 characters long, and can contain only lowercase letters, numbers, and hyphens.
// Random base on the resource group name.
var uniqueSurfix = substring(uniqueString(resourceGroup().id), 0, 5)
var cosmosDBName = 'cosmos-${resourceGroup().name}${uniqueSurfix}'

// Vnetname must be between 3 and 64 characters long, and can contain only letters, numbers, and hyphens. 
// Random base on the resource group name.
var primaryVnetName = 'vnet-primary-${uniqueSurfix}'
var secondaryVnetName = 'vnet-secondary-${uniqueSurfix}'

var cosmosPrimaryPEPName = 'pep-cosmos-primary-${uniqueSurfix}'
var cosmosSecondaryPEPName = 'pep-cosmos-secondary-${uniqueSurfix}'

var primaryDNSZoneName = 'primary${uniqueSurfix}.documents.azure.com'
var secondaryDNSZoneName = 'secondary${uniqueSurfix}.documents.azure.com'
resource vnet1 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: primaryVnetName
  location: primaryLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'appSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'dbSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: secondaryVnetName
  location: secondaryLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'appSubnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
      {
        name: 'dbSubnet'
        properties: {
          addressPrefix: '10.1.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'

        }
      }
    ]
  }
}

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

resource privateEndpoint1 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: cosmosPrimaryPEPName
  location: primaryLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'cosmosDBConnection'
        properties: {
          privateLinkServiceId: cosmosDB.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
    subnet: {
      id: vnet1.properties.subnets[1].id
    }
  }
}

resource privateEndpoint2 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: cosmosSecondaryPEPName
  location: secondaryLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'cosmosDBConnection'
        properties: {
          privateLinkServiceId: cosmosDB.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
    subnet: {
      id: vnet2.properties.subnets[1].id
    }
  }
}
resource privateDnsZone1 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: primaryDNSZoneName
  location: 'global'
  resource vnetLink1 'virtualNetworkLinks@2020-06-01' = {
    name: 'vnetLink1'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork:{
        id: vnet1.id
      }
    }
  }
}





resource privateDnsZone2 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: secondaryDNSZoneName
  location: 'global'
  resource vnetLink2 'virtualNetworkLinks@2020-06-01' = {
    name: 'vnetLink2'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnet2.id
      }
      registrationEnabled: false
    }
  }
}


resource privateDnsZoneGroup1 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  parent: privateEndpoint1
  name: 'dnszonegroup1'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone1.id
        }
      }
    ]
  }
}
resource privateDnsZoneGroup2 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  parent: privateEndpoint2
  name: 'dnszonegroup2'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone2.id
        }
      }
    ]
  }
}
