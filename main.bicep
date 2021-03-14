// All Parameters required for Azure Deployment is given here.
param rgName1 string
param rgName2 string
param adminUserName string
@secure()
param adminPassword string
param dnsLabelPrefix string

// ------------------------------
// Network Module is called here.
// ------------------------------
module network './network.bicep' = {
  name: 'VNET_DEPLOY1'
  scope: resourceGroup(rgName1)
  params:{}
}

// --------------------------------------
// Virtual Machine Module is called here.
// --------------------------------------
module vm './vm.bicep' = {
  name: 'VM_DEPLOY1'
  scope: resourceGroup(rgName2)
  params:{
    adminPassword:  adminPassword
    adminUserName:  adminUserName
    dnsLabelPrefix: dnsLabelPrefix
    vnet:           network.outputs.results.vnet
  }
}
