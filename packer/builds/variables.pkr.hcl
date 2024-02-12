variable "rgName" {
  type    = string
  default = "packer-rg"
}

variable "acgName" {
  type    = string
  default = "packer"
}

variable "image_name" {
  type    = string
  default = "bensspecialimage"
}

variable "build_key_vault_name" {
  type    = string
  default = "packer"
}

variable "build_revision" {
  type    = string
  default = "001"
}

variable "disk_encryption_set_id" {
  type    = string
  default = "/subscriptions/16d750eb-6d45-404c-a06a-a507a663be9e/resourceGroups/packer-rg/providers/Microsoft.Compute/diskEncryptionSets/packer"
}

variable "image_offer" {
  type    = string
  default = "WindowsServer"
}

variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsServer"
}

variable "image_sku" {
  type    = string
  default = "2022-datacenter-g2"
}

variable "temp_os_disk_name" {
  type    = string
  default = "osDisk001"
}

variable "destination_image_version" {
  type    = string
  default = "1.0.0"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vmSize" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "subscription_id" {
  type    = string
  default = "16d750eb-6d45-404c-a06a-a507a663be9e"
}

variable "tenant_id" {
  type    = string
  default = "ab2e4aa2-3855-48b9-8d02-619cee6d9513"
}

variable "client_id" {
  type    = string
  default = "de7f9841-0b1d-4840-93ab-fe36914baa04"
}

variable "client_secret" {
  type    = string
  default = "AwX8Q~u6mhGwbnOVu53IxUCcjSCUvnUM2ciPWduM"
}

variable "Release" {
  type    = string
  default = "COOL"
}