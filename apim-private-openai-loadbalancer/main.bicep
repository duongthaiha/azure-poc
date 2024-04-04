
param vnetName string 
param apimName string 
param applicationInsightsName string
param logAnalyticsWorkspaceName string
param publisherEmail string
param publisherName string
param keyVaultName string
param privateEndpointKeyVaultName string
param ptuAOAIName string
param paygAOAIName string
param privateEndpointPTUName string
param privateEndpointPaygName string
param vmName string
param vmUsername string
@secure()
param vmPassword string
param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location  
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
resource nsgApim 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-apim'
  location: location
  properties: {
    securityRules: [
      {
        name: 'apim-managment-portal'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'ApiManagement'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
        }
      }
      {
        name: 'apim-loadbalancer-inbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '6390'
        }
      }
      {
        name: 'apim-storage-outbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
          destinationPortRange: '443'
        }
      }
      {
        name: 'apim-sql-outbound'
        properties: {
          priority: 130
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Sql'
          destinationPortRange: '1433'
        }
      }
      {
        name: 'apim-keyvault-outbound'
        properties: {
          priority: 140
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
          destinationPortRange: '443'
        }
      }
      {
        name: 'apim-monitor-outbound'
        properties: {
          priority: 150
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureMonitor'
          destinationPortRanges: ['1886','443']
        }
      }
    ]
  }
}

resource nsgOpenAI 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-openai'
  location: location
}

resource nsgPep 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'nsg-pep'
  location: location
}
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-apim'
        properties: {
          addressPrefix: '10.0.0.0/25'
          networkSecurityGroup: {
            id: nsgApim.id
          }
        }
      }
      {
        name: 'snet-openai'
        properties: {
          addressPrefix: '10.0.1.0/26'
          networkSecurityGroup: {
            id: nsgOpenAI.id
          }
        }
      }
      {
        name: 'snet-pep'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsgPep.id
          }
        }
      }
      {
        name: 'snet-management'
        properties: {
          addressPrefix: '10.0.3.0/26'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.128/26'
        }
      }
    ]
  }
}
resource subnetapim 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'snet-apim'
  parent: vnet
}

resource subnetpep 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'snet-pep'
  parent: vnet
}

resource subnetaoai 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'snet-openai'
  parent: vnet
}


resource subnetmanagement 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'snet-management'
  parent: vnet
}

resource subnetbastion 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'AzureBastionSubnet'
  parent: vnet
}


resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-apim-management'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'apim-aoai-internal-management'
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apimName
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName:  publisherName
    virtualNetworkType: 'Internal'
    publicIpAddressId: publicIP.id
    virtualNetworkConfiguration: {
      subnetResourceId: subnetapim.id
    }
  }
  
}

resource apimlogger 'Microsoft.ApiManagement/service/loggers@2023-05-01-preview' = {
  name: applicationInsightsName
  parent: apim
  properties: {
    credentials: {
      instrumentationKey: applicationInsights.properties.InstrumentationKey
    }
    isBuffered: true
    loggerType: 'applicationInsights'
  }
}
resource apimdiagnostic 'Microsoft.ApiManagement/service/diagnostics@2023-05-01-preview' = {
  name: 'applicationinsights'
  parent: apim
  properties: {
    alwaysLog: 'allErrors'
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    loggerId: apimlogger.id
  }
}

resource ptuAOAI 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: ptuAOAIName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: ptuAOAIName
    apiProperties: {
      service: 'OpenAI'
    }
    publicNetworkAccess: 'Disabled'
  }
}
resource ptuGPT35Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: ptuAOAI
  name: 'gpt-35-turbo'
  properties: {
    model:{
      name: 'gpt-35-turbo'
      format: 'OpenAI'
      version: '0301'
    }
  }
  sku: {
    name: 'Standard'
    capacity: 1
  }
}
resource privateEndpointPTUAOAI 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointPTUName
  location: location
  properties: {
    subnet: {
      id: subnetaoai.id
    }
    privateLinkServiceConnections: [
      {
        name: 'plsConnectionAOAI'
        properties: {
          privateLinkServiceId: ptuAOAI.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}
resource privateDnsZoneAOAI 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.openai.azure.com'
  location: 'global'
  properties: {
    
  }
}
resource openAIDNSVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZoneAOAI
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}
resource privateDnsZoneGroupPTUAOAI 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: privateEndpointPTUAOAI
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneAOAI.id
        }
      }
    ]
  }
}

resource paygAOAI 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: paygAOAIName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: paygAOAIName
    apiProperties: {
      service: 'OpenAI'
    }
    publicNetworkAccess: 'Disabled'
  }
}
resource paygGPT35Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: paygAOAI
  name: 'gpt-35-turbo'
  properties: {
    model:{
      name: 'gpt-35-turbo'
      format: 'OpenAI'
      version: '0301'
    }
  }
  sku: {
    name: 'Standard'
    capacity: 1
  }
}
resource privateEndpointPaygAOAI 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointPaygName
  location: location
  properties: {
    subnet: {
      id: subnetaoai.id
    }
    privateLinkServiceConnections: [
      {
        name: 'plsConnectionAOAI'
        properties: {
          privateLinkServiceId: paygAOAI.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroupPaygAOAI 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: privateEndpointPaygAOAI
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneAOAI.id
        }
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    publicNetworkAccess: 'Disabled'
    enableRbacAuthorization:true
  }
}
resource ptuSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'aoai-ptu-key'
  properties: {
    value: ptuAOAI.listKeys().key1
    attributes: {
      enabled: true
    }
  }
}

resource paygSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'aoai-payg-key'
  properties: {
    value: paygAOAI.listKeys().key1
    attributes: {
      enabled: true
    }
  }
}


resource privateEndpointKeyvault 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointKeyVaultName
  location: location
  properties: {
    subnet: {
      id: subnetpep.id
    }
    privateLinkServiceConnections: [
      {
        name: 'plsConnection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}
resource privateDnsZoneKeyVault 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
}
resource keyvaultDNSVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZoneKeyVault
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: privateEndpointKeyvault
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneKeyVault.id
        }
      }
    ]
  }
}


resource backendPTU 'Microsoft.ApiManagement/service/backends@2021-04-01-preview' = {
  parent: apim
  name: 'AOAI_PTU'
  properties: {
    url: '${ptuAOAI.properties.endpoint}openai'
    protocol: 'http'
   
  }
}



resource paygPTU 'Microsoft.ApiManagement/service/backends@2021-04-01-preview' = {
  parent: apim
  name: 'AOAI_PAYO'
  properties: {
    url: '${paygAOAI.properties.endpoint}openai'
    protocol: 'http'
  }
}

@description('This is the built-in SecretUser role')
resource secretUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
} 
// resource secretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(apim.id, secretUserRoleDefinition.id, resourceGroup().name)
//   properties: {
//     principalId: apim.identity.principalId
//     roleDefinitionId: secretUserRoleDefinition.id
//     principalType: 'ServicePrincipal'
//   }
//   scope:keyVault
// }



@description('This is the built-in SecretUser role')
resource openaiUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
} 
// resource ptuOpenAIUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(apim.id, openaiUserRoleDefinition.id, resourceGroup().name,ptuAOAIName)
//   properties: {
//     principalId: apim.identity.principalId
//     roleDefinitionId: openaiUserRoleDefinition.id
//     principalType: 'ServicePrincipal'
//   }
//   scope:ptuAOAI
// }

// resource paygOpenAIUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(apim.id, openaiUserRoleDefinition.id, resourceGroup().name, paygAOAIName)
//   properties: {
//     principalId: apim.identity.principalId
//     roleDefinitionId: openaiUserRoleDefinition.id
//     principalType: 'ServicePrincipal'
//   }
//   scope:paygAOAI
// }

// resource namedValuePtuKey 'Microsoft.ApiManagement/service/namedValues@2021-04-01-preview' = {
//   parent: apim
//   name: 'aoai-ptu-key'
//   properties: {
//     displayName: 'aoai-ptu-key'
//     secret: true
//     keyVault:{
//       secretIdentifier:ptuSecret.properties.secretUri
//     }
    
//   }
// }

// resource namedValuePaygKey 'Microsoft.ApiManagement/service/namedValues@2021-04-01-preview' = {
//   parent: apim
//   name: 'aoai-payg-key'
//   properties: {
//     displayName: 'aoai-payg-key'
//     secret: true
//     keyVault:{
//       secretIdentifier:paygSecret.properties.secretUri
//     }
//   }
// }

resource api 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apim
  name: 'OpenAI'
  properties: {
    format:'openapi'
    value: loadTextContent('openai.json')
    path: 'aoai'
    protocols: [
      'https'
    ]
  }
}
resource policy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  name: 'policy'
  parent: api
  properties: {
    format: 'xml'
    value: loadTextContent('policy.xml')
  }
}


resource publicManagementIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-bastion'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vmName}NIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetmanagement.id
          }
          privateIPAllocationMethod: 'Dynamic'
          
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: substring(vmName, 0, 15)
      adminUsername: vmUsername
      adminPassword: vmPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: '${vmName}BastionHost'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionHostIpConfig'
        properties: {
          subnet: {
            id: subnetbastion.id
          }
          publicIPAddress: {
            id: publicManagementIP.id
          }
          
        }
      }
    ]
  }
}
