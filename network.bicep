// All Parameters required for Network Deployment is given here.
param location string = resourceGroup().location

// All Variables required for Network Deployment is given here.
var addressPrefix = '10.10.0.0/16'
var subnetName = 'Subnet1'
var subnetPrefix = '10.10.1.0/24'
var virtualNetworkName = 'VNET1'
var subnetRef = '${vn.id}/subnets/${subnetName}'
var networkSecurityGroupName = 'default-NSG'

// -------------------------------------------------
// Azure Network Security Group Resource is created.
// -------------------------------------------------
resource sg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        'properties': {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ------------------------------------------
// Azure Virtual Network Resource is created.
// ------------------------------------------
resource vn 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: sg.id
          }
        }
      }
    ]
  }
}

// The above vnet is passed as an object, so that it can be used by another module.
output results object = {
  vnet: vn
}