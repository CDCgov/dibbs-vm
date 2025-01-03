packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3.4"
    }
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2.2.0"
    }
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1.1.4"
    }
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.1.0"
    }
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1.4.2"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1.1.1"
    }
  }
}

source "qemu" "iso" {
vm_name              = "ubuntu-2404-ecrViewer.raw"
  # Uncomment this block to use a basic Ubuntu 24.04 cloud image
  # iso_url              = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
  # iso_checksum         = "sha256:b63f266fa4bdf146dea5b0938fceac694cb3393688fb12a048ba2fc72e7bfe1b"
  # disk_image           = true

  # Uncomment this block to configure Ubuntu 24.04 server from scratch
  iso_url              = "http://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
  iso_checksum         = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  disk_image           = false

  memory               = 4096
  output_directory     = "build/os-base"
  //accelerator          = "hvf"
  disk_size            = "8000M"
  disk_interface       = "virtio"
  format               = "raw"
  net_device           = "virtio-net"
  boot_wait            = "3s"
  #boot_command         = [
  #  "e<wait>",
  #  "<down><down><down><end>",
  #  " autoinstall ds=\"nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/\" ",
  #  "<f10>"
  #  ]
  boot_command = [
  "c<wait>linux /casper/vmlinuz --- autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
  "initrd /casper/initrd<enter><wait><wait>",
  "boot<enter><wait>"
]
  # boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
  http_directory       = "http"
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_timeout          = "60m"
  machine_type         = "q35"
  cpus                 = 2
  headless             = true
}

/*source "virtualbox-iso" "ecr-viewer" {

}*/

build {
  name = "iso"

  sources = [
    "source.qemu.iso"
  ]
}