
param vnetName string 
param apimName string 
param applicationInsightsName string
param logAnalyticsWorkspaceName string
param publisherEmail string ='haduong@microsoft.com'
param publisherName string = 'Microsoft'

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
  name: 'ai-logger'
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
  name: 'ai-diagnostic'
  parent: apim
  properties: {
    alwaysLog: true
    sampling: {
      samplingType: 'fixed'
      samplingPercentage: 100
    }
    loggerId: apimlogger.id
  }
}
