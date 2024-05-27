# Data Source for existing Core Keyvault - for local sudoer secrets
data "azurerm_key_vault" "kv" {
  name                = var.keyVault
  resource_group_name = var.rgKeyVault
}

# Data source for existing subnet to match information provided in json
data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.rgVnet
}


#######################################################################################

# Create Password for vm
resource "random_password" "vmPass" {
  length           = 16
  special          = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "!@#$%"
}

# save password in keyvault secret
resource "azurerm_key_vault_secret" "vmSecret" {
  name         = var.vm
  value        = random_password.vmPass.result
  key_vault_id = data.azurerm_key_vault.kv.id
  tags = {
    ProvisioningMode = "Terraform",
    ProvisioningDate = timestamp()
  }
  lifecycle {
    ignore_changes = [
      value,
      tags,
    ]
  }
}

# import storage account for VM diag
data "azurerm_storage_account" "vmDiag" {
  name                     = var.vmDiagSta
  resource_group_name      = var.rgVmDiagSta
}

# Create 1 NIC pour each VM
resource "azurerm_network_interface" "vmNic0" {
  name                = "${var.vm}Nic0"
  resource_group_name = var.rgName
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id 
    private_ip_address_allocation = "Dynamic"
  }
}

# Create n VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm
  computer_name                   = var.vm
  resource_group_name             = var.rgName
  location                        = var.location
  size                            = var.size
  admin_username                  = var.adminName
  admin_password                  = random_password.vmPass.result 
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.vmNic0.id,
  ]
  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.vmDiag.primary_blob_endpoint
  }

  identity {
    type = var.user_identity == [] ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.user_identity
  }

  os_disk {
    name                 = "${var.vm}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.vmStorageTier 
    disk_size_gb         = var.osDiskSize
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.vmVersion
  }

  zone = var.zone

  tags = {
    ProvisioningMode = "Terraform",
    ProvisioningDate = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_machine_extension" "azureAdAuth" {
  name                 = "AADSSHLoginForLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0"
}

resource "azurerm_managed_disk" "dataDisk" {
  for_each             = { for i in var.disks : "${var.vm}Disk${i.lunId}"=>{size=i.size,lunId=i.lunId}}
  name                 = each.key
  resource_group_name  = var.rgName
  location             = var.location
  storage_account_type = var.vmStorageTier
  create_option        = var.createOption
  disk_size_gb         = each.value.size
  zone                 = var.zone

  tags = {
    ProvisioningMode = "Terraform",
    ProvisioningDate = timestamp()
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "dataDisk-Attachment" {
  for_each           = { for i in var.disks : "${var.vm}Disk${i.lunId}"=>{size=i.size,lunId=i.lunId}}
  managed_disk_id    = azurerm_managed_disk.dataDisk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = each.value.lunId
  caching            = "ReadWrite"
}
