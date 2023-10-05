#Module Output
output "vmName" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "subnetId" {
  value = data.azurerm_subnet.subnet.id
}

output "vmId" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "vmIdentity" {
  value = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "vmNicId" {
  value = azurerm_network_interface.vmNic0.id
}

output "vmIp" {
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}