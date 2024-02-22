// demo + pr

variable "azure_subscription_id" {
  type    = string
  description = "The subscription id of the service principal, store in GitHub secrets"
  default = ""
}

variable "azure_tenant_id" {
  type    = string
  description = "The tenant id of the service principal, store in GitHub secrets"
  default = ""
}

variable "azure_client_id" {
  type    = string
  description = "The client id of the service principal, store in GitHub secrets"
  default = ""
}

variable "azure_client_secret" {
  type    = string
  description = "The client secret of the service principal, store in GitHub secrets"
  default = ""
}


packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

locals {
  time = formatdate("YYYYMMDDhhmmss",timestamp()) # Year Month Day Hour Minute Second with padding.
}

source "azure-arm" "windows" {

  // Grab the latest version of the Windows Server 2019 Datacenter
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"

//  Managed images and resource group.
  managed_image_name = "packer-image-${local.time}"
  managed_image_resource_group_name = "packer-rg"


  
  vm_size = "Standard_DS1_v2"
  temp_resource_group_name = "packer-rg-temp-${local.time}"
  location = "East US"
  os_type = "Windows"

// // Create a managed image and share it to a gallery
// shared_image_gallery_destination {
//     subscription        = "${var.azure_subscription_id}"
//     gallery_name        = "packer_acg"
//     image_name          = "windows"
//     image_version       = "1.0.0"
//     replication_regions = ["Australia East", "Australia Southeast"]
//     resource_group      = "packer-rg"
//   }

// These are passed in the pipeline.

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id

// WinRM Connection, this is recommended for Windows, SSH would be the recommendation for Linux distributions.
  communicator = "winrm"
  winrm_insecure                     = true
  winrm_timeout                      = "7m"
  winrm_use_ssl                      = true
  winrm_username                     = "packer"
}

build {
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    pause_before = "5s"
    inline = [
      "Write-Host '***** this is a demo message *****'"
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

  hcp_packer_registry {
    bucket_name = "windows-2019-base"
    description = <<EOT
    You can put any arbitrary text here. This is just an example. I will say, 'hi gabe and class.'
    EOT
    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "windows",
      "version" = "2019",
      }
    build_labels = {
    "build-time"   = timestamp()
    "build-source" = basename(path.cwd)
    }
  }
}
