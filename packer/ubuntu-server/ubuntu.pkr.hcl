// This Packer template for dibbs-vm is used to build a QEMU image for Ubuntu 24.04 server.
// It includes configurations for various required plugins and a QEMU source definition.
// The build process provisions the VM with necessary scripts and files.

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
    # hyperv = {
    #   source  = "github.com/hashicorp/hyperv"
    #   version = "~> 1.1.4"
    # }
    # proxmox = {
    #   version = ">= 1.2.2"
    #   source  = "github.com/hashicorp/proxmox"
    # }
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.1.0"
    }
    # vsphere = {
    #   source  = "github.com/hashicorp/vsphere"
    #   version = "~> 1.4.2"
    # }
    # virtualbox = {
    #   source  = "github.com/hashicorp/virtualbox"
    #   version = "~> 1.1.1"
    # }
  }
}

source "qemu" "raw" {
  vm_name = "ubuntu-2404-${var.dibbs_service}-raw-${var.dibbs_version}-${var.gitsha}.raw"
  # Uncomment this block to use a basic Ubuntu 24.04 cloud image
  # iso_url              = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
  iso_url          = "http://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum     = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  disk_image       = false
  memory           = 4096
  output_directory = "build/${var.dibbs_service}-raw-${var.dibbs_version}-${var.gitsha}"
  disk_size        = "24000M"
  disk_interface   = "virtio"
  format           = "raw"
  net_device       = "virtio-net"
  boot_wait        = "3s"
  boot_command = [
    "c<wait>linux /casper/vmlinuz --- autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait><wait>",
    "boot<enter><wait>"
  ]
  http_directory   = "http"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_username     = "dibbs-user"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "60m"
  machine_type     = "q35"
  cpus             = 2
  headless         = true
}

source "qemu" "gcp" {
  vm_name = "ubuntu-2404-${var.dibbs_service}-gcp-${var.dibbs_version}-${var.gitsha}.raw"
  # Uncomment this block to use a basic Ubuntu 24.04 cloud image
  # iso_url              = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
  iso_url          = "http://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum     = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  disk_image       = false
  memory           = 4096
  output_directory = "build/${var.dibbs_service}-gcp-${var.dibbs_version}-${var.gitsha}"
  disk_size        = "24000M"
  disk_interface   = "virtio"
  format           = "raw"
  net_device       = "virtio-net"
  boot_wait        = "3s"
  boot_command = [
    "c<wait>linux /casper/vmlinuz --- autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait><wait>",
    "boot<enter><wait>"
  ]
  http_directory   = "http"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_username     = "dibbs-user"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "60m"
  machine_type     = "q35"
  cpus             = 2
  headless         = true
}

/*source "virtualbox-iso" "ecr-viewer" {

}*/



source "amazon-ebs" "aws-ami" {
  ami_name      = "ubuntu-2404-${var.dibbs_service}-${var.dibbs_version}-${var.gitsha}"
  instance_type = var.aws_instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical's official AWS account ID
    most_recent = true
  }

  //TODO: CHANGE ME! Change the password to use the random one, too!
  ssh_username = "ubuntu"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "Ubuntu-2404-${var.dibbs_service}-${var.dibbs_version}-${var.gitsha}"
    Environment = "Dev"
  }
}

source "azure-arm" "azure-image" {
  azure_tags = {
    dept = "Dev"
    task = "Image deployment"
  }

  subscription_id                   = var.subscription_id
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  tenant_id                         = var.tenant_id
  location                          = "eastus"
  vm_size                           = "Standard_D2s_v3"
  image_publisher                   = "Canonical"
  image_offer                       = "ubuntu-24_04-lts"
  image_sku                         = "server"
  managed_image_name                = "Ubuntu-2404-${var.dibbs_service}-${var.dibbs_version}-${var.gitsha}"
  managed_image_resource_group_name = "skylight-dibbs-vm1"
  os_type                           = "Linux"

  //TODO: CHANGE ME! Change the password to use the random one, too!
  ssh_username = "ubuntu"

}


build {
  name = "multi-cloud-build"
  sources = [
    // "source.qemu.raw"
    "source.qemu.gcp"
    //"source.amazon-ebs.aws-ami",
    //"source.azure-arm.azure-image"
  ]

  provisioner "file" {
    source      = "./jails/jail.local"
    destination = "~/jail.local"
  }

  provisioner "shell" {
    only = ["azure-arm.azure-image"]
    scripts = [
      "scripts/fail2ban.sh",
      "scripts/post-install.sh",
      "scripts/provision.sh"
    ]
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "USE_SUDO=sudo",
      "BUILD_TYPE=azure"
    ]

    //TODO: Add new password here!
    execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }

  provisioner "shell" {
    only = ["amazon-ebs.aws-ami"]
    scripts = [
      "scripts/fail2ban.sh",
      "scripts/post-install.sh",
      "scripts/provision.sh"
    ]
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "USE_SUDO=",
      "BUILD_TYPE=aws"
    ]

    //TODO: Add new password here!
    execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }

  provisioner "shell" {
    only = ["qemu.raw"]
    scripts = [
      "scripts/fail2ban.sh",
      "scripts/provision.sh"
    ]
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}"
    ]
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }

  provisioner "shell" {
    only = ["qemu.gcp"]
    scripts = [
      "scripts/fail2ban.sh",
      "scripts/provision.sh"
    ]
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "BUILD_TYPE=gcp"
    ]
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }

  provisioner "file" {
    source      = "../../${var.dibbs_service}/${var.dibbs_service}-wizard.sh.home"
    destination = "~/${var.dibbs_service}-wizard.sh"
  }

  provisioner "file" {
    source      = "./scripts/hot-upgrade.sh.home"
    destination = "~/hot-upgrade.sh"
  }

  provisioner "file" {
    source      = "./scripts/apt-updates.sh.home"
    destination = "~/apt-updates.sh"
  }
}
