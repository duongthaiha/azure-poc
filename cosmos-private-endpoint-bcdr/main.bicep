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
var primaryVnetName = 'vnet-primary-${resourceGroup().name}${uniqueSurfix}'
var secondaryVnetName = 'vnet-secondary-${resourceGroup().name}${uniqueString(uniqueSurfix)}'

var cosmosPrimaryPEPName = 'pep-cosmos-primary-${resourceGroup().name}${uniqueSurfix}'
var cosmosSecondaryPEPName = 'pep-cosmos-secondary-${resourceGroup().name}${uniqueSurfix}'

var primaryDNSZoneName = 'primary${uniqueSurfix}.documents.azure.com'
var secondaryDNSZoneName = 'secondary${uniqueSurfix}.documents.azure.com'
resource vnet1 'Microsoft.Network/virtualNetworks@2021-02-01' = {
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
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-02-01' = {
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
        }
      }
    ]
  }
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: cosmosDBName
  location: primaryLocation
  kind: 'GlobalDocumentDB'
  properties: {
    locations: [
      {
        locationName: 'eastus'
        failoverPriority: 0
        isZoneRedundant: false
      }
      {
        locationName: 'eastus2'
        failoverPriority: 1
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

resource privateEndpoint1 'Microsoft.Network/privateEndpoints@2021-02-01' = {
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

resource privateEndpoint2 'Microsoft.Network/privateEndpoints@2021-02-01' = {
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
}


resource vnetLink1 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone1
  name: 'vnetLink1'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet1.id
    }
    registrationEnabled: true
  }
}


resource privateDnsZone2 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: secondaryDNSZoneName
  location: 'global'
}

resource vnetLink2 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone2
  name: 'vnetLink2'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet2.id
    }
    registrationEnabled: true
  }
}
resource privateDnsZoneGroup1 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: privateEndpoint1
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone1.id
        }
      }
    ]
  }
}
resource privateDnsZoneGroup2 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: privateEndpoint2
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone2.id
        }
      }
    ]
  }
}
