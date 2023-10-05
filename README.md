# Linux VMs Module
This module creates a linux VM, with data disks and dependant resources
- 1 Linux Virtual Machines
- VM Extensions (azure ad auth)
- 1 NIC
- n Managed Disks attached VM
- Keyvault secrets for primary sudo user Password (to be stored in Existing Core Keyvault)

## Required resources :
- existing Keyvault
- existing storage account for diag
- existing Vnet (to specify as input variable)
- existing subnet (to specify in the vm configurations in the json)

## Usage Example :

```hcl
resource "azurerm_resource_group" "rg" {
  name = "myRg"
  location = "westeurope"
}

module "vm" {
  source = "github.com/nfrappart/azTerraVmLinuxAz?ref=v1.0.0"
  vm            = "myVm"
  adminName     = "localadm"
  publisher     = "Canonical
  offer         = "0001-com-ubuntu-server-jammy"
  sku           = "22_04-lts-gen2"
  vmVersion     = "latest"
  size          = "Standard_B1ms"
  zone          = "1"
  osDiskSize    = "64"
  disks         = [
      {
        lunId = "1",
        size  = "32"
      }
    ]
  subnet        = "mySubnet"
  rgName        = azurerm_resource_group.rg.name
  keyVault      = "myKv" # reference existing key vault
  rgKeyVault    = "rgMyKv" # reference keyvault resource group name
  vmDiagSta     = "mystorageaccount" # reference existing storage account
  rgVmDiagSta   = "rgStorageAccount" # reference strage account resource group name 
  vnet          = "myVnet"
  rgVnet        = "rgMyNetwork"
  location      = azurerm_resource_group.rg.location
}
```