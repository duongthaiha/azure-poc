param location string = resourceGroup().location    
param vnetName string = 'vnet-aci-acr' 
param addressPrefix string = '10.0.0.0/16'
param acrSubnetName string = 'acr-subnet'
param acrSubnetPrefix string = '10.0.0.0/24'
param aciSubnetName string = 'aci-subnet'
param aciSubnetPrefix string = '10.0.1.0/24'
param acrName string = 'acr${uniqueString(resourceGroup().id)}'
param AZP_URL string
param AZP_TOKEN string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
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
        name: acrSubnetName
        properties: {
          addressPrefix: acrSubnetPrefix
        }
      }
      {
        name: aciSubnetName
        properties: {
          addressPrefix: aciSubnetPrefix
          delegations: [
            {
              name: 'aci-delegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ]
  }
  resource acrSubnet 'subnets' existing = {
    name: acrSubnetName
  }

  resource aciSubnet'subnets' existing = {
    name: aciSubnetName

  }
}
resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${acrName}-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: virtualNetwork::acrSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${acrName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: containerRegistry.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
  }
}
resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurecr.io'
  location: 'global'
  
}
resource privateDNSZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'private-dns-zone-link'
  location:'global'
  parent: privateDNSZone
  properties: {
    virtualNetwork: {
      id: virtualNetwork.id
    }
    registrationEnabled: true
  }
}
resource acrPrivateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${acrName}-private-dns-zone-group'
  parent: acrPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
}
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: 'Disabled'
    
  }
}

resource selfHostAgentInstance 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'self-host-agent'
  location: location
  properties: {
    containers: [
      {
        name: 'self-host-agent'
        properties: {
          image: 'duongthaiha/dockeragent:latest'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          environmentVariables: [
            {
              name: 'AZP_TOKEN'
              secureValue: AZP_TOKEN
            }
            {
              name: 'AZP_URL'
              value: AZP_URL
            }
            {
              name: 'AZP_AGENT_NAME'
              value: 'mydockeragent'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    subnetIds: [
     {
      id: virtualNetwork::aciSubnet.id
     }
    ]
  }
}

output acrSubnetResourceId string = virtualNetwork::acrSubnet.id
output aciSubnetResourceId string = virtualNetwork::aciSubnet.id
output virutalNetworkId string = virtualNetwork.id
 