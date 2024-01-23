targetScope = 'subscription'
param primaryLocation string ='uksouth'
param secondaryLocation string = 'ukwest'
param namePattern string = 'cosmos-poc-2'
//Create global resources

resource globalGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${namePattern}-global'
  location: primaryLocation
}
module cosmos 'globalresource.bicep' = {
  name: 'cosmos'
  scope: globalGroup
  params: {
    primaryLocation: primaryLocation
    secondaryLocation: secondaryLocation
    cosmosDBName: 'cosmos-${namePattern}'
  }
}


//Deploy the primary region 
resource primaryGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${namePattern}-primary'
  location: primaryLocation
}
module primaryRegion 'regionalvnet.bicep' = {
  scope: primaryGroup 
  name: 'primaryRegion'
  params: {
    addressPrefix: '10.0.0.0/16'
    appSubnet: '10.0.1.0/24'
    cosmosID: cosmos.outputs.cosmosId
    dbSubnet: '10.0.2.0/24'
    location: primaryLocation
    vnetName: 'vnet-${namePattern}-primary'
  }
}


//Deploy the secondary region
resource secondaryGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${namePattern}-secondary'
  location: secondaryLocation
}
module secondaryRegion 'regionalvnet.bicep' = {
  scope: secondaryGroup 
  name: 'secondaryRegion'
  params: {
    addressPrefix: '10.1.0.0/16'
    appSubnet: '10.1.1.0/24'
    cosmosID: cosmos.outputs.cosmosId
    dbSubnet: '10.1.2.0/24'
    location: primaryLocation
    vnetName: 'vnet-${namePattern}-secondary'
  } 
}
