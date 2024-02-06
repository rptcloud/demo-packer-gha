packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable "rgName" {
  type    = string
  default = "rg-acg-test"
}

variable "acgName" {
  type    = string
  default = "acgDemo"
}

variable "image_name" {
  type    = string
  default = "WindowsImage"
}

variable "build_key_vault_name" {
  type    = string
  default = "kv-demo"
}

variable "build_revision" {
  type    = string
  default = "001"
}

variable "disk_encryption_set_id" {
  type    = string
  default = "/subscriptions/<REPLACE_WITH_YOUR_SUBSCRIPTION_ID>/resourceGroups/<REPLACE_WITH_YOUR_RG_NAME>/providers/Microsoft.Compute/diskEncryptionSets/<DES_NAME>"
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
  default = "westeurope"
}

variable "vmSize" {
  type    = string
  default = "Standard_DS3_V2"
}

variable "subscription_id" {
  type    = string
  default = "<REPLACE_WITH_YOUR_SUBSCRIPTION_ID>"
}

variable "tenant_id" {
  type    = string
  default = "<REPLACE_WITH_YOUR_TENANT_ID>"
}

variable "client_id" {
  type    = string
  default = "<REPLACE_WITH_YOUR_CLIENT_ID>"
}

variable "client_secret" {
  type    = string
  default = "<REPLACE_WITH_YOUR_CLIENT_SECRET>"
}

variable "Release" {
  type    = string
  default = "COOL"
}

source "azure-arm" "imageBuild" {
  
  azure_tags = {
    "Env"             = "Dev"
    "Image Offer"     = "${var.image_offer}"
    "Image Publisher" = "${var.image_publisher}"
    "Image SKU"       = "${var.image_sku}"
    "Task"            = "Packer"
  }

  build_key_vault_name                = "${var.build_key_vault_name}"
  # temp_resource_group_name            = "rg-packer-temp"
  # location                           = "${var.location}"
  build_resource_group_name           = "${var.rgName}"
  client_id                           = "${var.client_id}"
  client_secret                       = "${var.client_secret}"
  communicator                        = "winrm"
  disk_encryption_set_id              = "${var.disk_encryption_set_id}"

# USE MARKETPLACE IMAGE AS SOURCE

  image_offer                         = "${var.image_offer}"
  image_publisher                     = "${var.image_publisher}"
  image_sku                           = "${var.image_sku}"

# USE SHARED GALLERY AS SOURCE

  # shared_image_gallery {
  #     subscription = "${var.subscription_id}"
  #     resource_group = "${var.rgName}"
  #     gallery_name = "${var.acgName}"
  #     image_name = "${var.image_name}"
  #     image_version = "${var.source_image_version}"
  # }

  os_type                             = "Windows"

  # UNCOMMENT THE LINES BELOW TO ENABLE Trusted Launch
  # secure_boot_enabled                 = true
  # vtpm_enabled                        = true

  keep_os_disk                        = true
  temp_os_disk_name                   = "${var.temp_os_disk_name}"

  shared_image_gallery_destination {
    subscription        = "${var.subscription_id}"
    gallery_name        = "${var.acgName}"
    image_name          = "${var.image_name}"
    image_version       = "${var.destination_image_version}"
    # replication_regions = ["${var.location}"]
    resource_group      = "${var.rgName}"
  }
  # shared_image_gallery_replica_count = 1

  # # Trying Managed Instance Output

  # managed_image_name                 = "${var.managed_image_name}"
  # managed_image_resource_group_name  = "${var.rgName}"

  subscription_id                    = "${var.subscription_id}"
  tenant_id                          = "${var.tenant_id}"
  vm_size                            = "${var.vmSize}"
  winrm_insecure                     = true
  winrm_timeout                      = "7m"
  winrm_use_ssl                      = true
  winrm_username                     = "packer"
}

build {
  sources = ["source.azure-arm.imageBuild"]

//   provisioner "file" {
//     source = "demo.zip"
//     destination = "C:/"
//   }

  provisioner "powershell" {
    pause_before = "5s"
    inline = [
      "Write-Host '***** this is a demo message *****'"
    ]
  }

# Initiating a system restart
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'Restarted.'}\""
    pause_before  = "30s"
  }

  provisioner "powershell" {
    # pause_before = "30s"
    environment_vars = [
      "Release=${var.Release}"
    ]
    inline = [
      "Write-Host \"Release version is: $Env:Release\"",        
    ]
  }

# Generalising the image
  
  provisioner "powershell" {
    inline = [ 
      "Write-host '=== Azure image build completed successfully ==='",
      "Write-host '=== Generalising the image ... ==='",    
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /generalize /oobe /quit", 
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }

# Output a manifest file
  post-processor "manifest" {
      output = "packer-manifest.json"
      strip_path = true
      custom_data = {
        run_type            = "test_acg_run"
        subscription        = "${var.subscription_id}"
        gallery_name        = "${var.acgName}"
        image_name          = "${var.image_name}"
      }
  }
}
