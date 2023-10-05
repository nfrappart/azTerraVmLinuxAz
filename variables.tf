
variable "vmDiagSta" {
  type = string
}
variable "rgVmDiagSta" {
  type = string
}
variable "vm" {
  type = string
}
variable "adminName" {
  type = string
}
variable "publisher" {
  type = string
}
variable "offer" {
  type = string
}
variable "sku" {
  type = string
}
variable "vmVersion" {
  type = string
}
variable "size" {
  type = string
}
variable "zone" {
  type = string
}
variable "osDiskSize" {
  type = string
}
variable "disks" {
  type = list(object({
    lunId = string,
    size = string
  }))
}

variable "rgName" {
  type = string
}

variable "keyVault" {
  type = string
}

variable "rgKeyVault" {
  type = string
}

variable "vnet" {
  type = string
}

variable "subnet" {
  type = string
}

variable "rgVnet" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

#The Managed Disk Storage tier
variable "vmStorageTier" {
  type    = string
  default = "Premium_LRS"
}

variable "createOption" {
  type    = string
  default = "Empty"
}
