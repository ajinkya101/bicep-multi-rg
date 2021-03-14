// All Parameters required for VM Deployment is given here.
param adminUserName string
@secure()
param adminPassword string
param dnsLabelPrefix string
@description('location for all resources')
param location string = resourceGroup().location

// All Variables required for VM Deployment is given here.
var windowsOSVersion  = '2016-Datacenter'
var vmSize  = 'Standard_B2s'
var nicName = 'myVMNic'
var publicIPAddressName = 'myPublicIP'
var vmName = 'Win2016Server'
var networkSecurityGroupName = 'default-NSG'

// Passing parameters and variables for network resources.
param vnet object
param subnetName string = 'Subnet1'
var vnetName = last(split(vnet.resourceId, '/'))
var subnetId = resourceId(vnet.resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

// ------------------------------------
// Azure Public IP Resource is created.
// ------------------------------------
resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

// --------------------------------------------
// Azure Network Interface Resource is created.
// --------------------------------------------
resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

// --------------------------------------------------
// Azure Windows Virtual Machine Resource is created.
// --------------------------------------------------
resource VM 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 128
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nInter.id
        }
      ]
    }
  }
}
