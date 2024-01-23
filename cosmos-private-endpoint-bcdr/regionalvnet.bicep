param vnetName string
param location string
param addressPrefix string
param appSubnet string
param dbSubnet string
param cosmosID string
resource vnet1 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'appSubnet'
        properties: {
          addressPrefix: appSubnet
        }
      }
      {
        name: 'dbSubnet'
        properties: {
          addressPrefix: dbSubnet
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource privateEndpoint1 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'cosmos-privateEndpoint'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'cosmosDBConnection'
        properties: {
          privateLinkServiceId: cosmosID
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
resource privateDnsZone1 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.documents.azure.com'
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
