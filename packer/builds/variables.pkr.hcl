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
  default = "16f1299e-c5d6-4d0a-8c74-35852359c75b"
}

variable "tenant_id" {
  type    = string
  default = "ab2e4aa2-3855-48b9-8d02-619cee6d9513"
}

variable "client_id" {
  type    = string
  default = "f95d2750-6221-4ff3-aa59-9f50d4c50634"
}

variable "client_secret" {
  type    = string
  default = "jSJ8Q~RAb0XrLLRuv0Dtpd7.h6tjwmLxjKgsQawc"
}

variable "Release" {
  type    = string
  default = "COOL"
}