//testing workflow again

packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

locals {
  time = formatdate("DDMMMYYYY",timestamp())
}

source "azure-arm" "windows" {
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"
  managed_image_name = "packer-image-${local.time}"
  managed_image_resource_group_name = "packer-rg"

  vm_size = "Standard_DS1_v2"

  temp_resource_group_name = "packer-rg-temp-${local.time}"
  location = "East US"

  os_type = "Windows"

shared_image_gallery_destination {
    subscription        = "${var.subscription_id}"
    gallery_name        = "packer_acg"
    image_name          = "windows"
    image_version       = "1.0.0"
    replication_regions = ["East US"]
    resource_group      = "packer-rg"
  }

// These are accessed from the environment variables. 
  // subscription_id = var.subscription_id
  // client_id       = var.client_id
  // client_secret   = var.client_secret
  // tenant_id       = var.tenant_id

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


}

