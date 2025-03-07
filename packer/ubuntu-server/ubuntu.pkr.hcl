// This Packer template for dibbs-vm is used to build a QEMU image for Ubuntu 24.04 server.
// It includes configurations for various required plugins and a QEMU source definition.
// The build process provisions the VM with necessary scripts and files.

packer {
  required_plugins {
     amazon = {
     source  = "github.com/hashicorp/amazon"
     version = "~> 1.3.4"
     }
    # azure = {
    #   source  = "github.com/hashicorp/azure"
    #   version = "~> 2.2.0"
    # }
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

<<<<<<< HEAD
=======


>>>>>>> 4f9b5dd (updated AWS to use a unified provison.sh script)
source "qemu" "iso" {
  vm_name = "ubuntu-2404-${var.dibbs_service}-${var.dibbs_version}.raw"
  # Uncomment this block to use a basic Ubuntu 24.04 cloud image
  # iso_url              = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
<<<<<<< HEAD
  iso_url          = "http://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum     = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  disk_image       = false
  memory           = 4096
  output_directory = "build/${var.dibbs_service}-${var.dibbs_version}"
  disk_size        = "24000M"
  disk_interface   = "virtio"
  format           = "raw"
  net_device       = "virtio-net"
  boot_wait        = "3s"
=======
  # iso_checksum         = "sha256:28d2f9df3ac0d24440eaf6998507df3405142cf94a55e1f90802c78e43d2d9df"
  # disk_image           = true

  # Uncomment this block to configure Ubuntu 24.04 server from scratch
  iso_url      = "http://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  disk_image   = false

  memory           = 4096
  output_directory = "build/${var.dibbs_service}-${var.dibbs_version}"
  //accelerator          = "hvf"
  disk_size      = "8000M"
  disk_interface = "virtio"
  format         = "raw"
  net_device     = "virtio-net"
  boot_wait      = "3s"
  #boot_command         = [
  #  "e<wait>",
  #  "<down><down><down><end>",
  #  " autoinstall ds=\"nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/\" ",
  #  "<f10>"
  #  ]
>>>>>>> 391e050 (Modified ubuntu.pkr.hcl to reflect new variables)
  boot_command = [
    "c<wait>linux /casper/vmlinuz --- autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait><wait>",
    "boot<enter><wait>"
  ]
<<<<<<< HEAD
=======
  # boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
>>>>>>> 391e050 (Modified ubuntu.pkr.hcl to reflect new variables)
  http_directory   = "http"
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "60m"
  machine_type     = "q35"
  cpus             = 2
  headless         = true
}

/*source "virtualbox-iso" "ecr-viewer" {

}*/



source "amazon-ebs" "aws-ami" {
  ami_name      = "ubuntu-2404-${var.dibbs_service}-${var.dibbs_version}"
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

  ssh_username = "ubuntu"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "Ubuntu-2404-${var.dibbs_service}-${var.dibbs_version}"
    Environment = "Dev"
  }
}

build {
  name = "multi-build"

  sources = [
    "source.qemu.iso",
    "source.amazon-ebs.aws-ami"
  ]

<<<<<<< HEAD
<<<<<<< HEAD
  # AWS-Specific Post-Install Provisioner
  provisioner "shell" {
    only   = ["amazon-ebs.aws-ami"]
    script = "scripts/post-install.sh"
=======
  # AWS-Specific Post-Install Provisioner (Runs Only on AWS)
=======
  # AWS-Specific Post-Install Provisioner
>>>>>>> 391e050 (Modified ubuntu.pkr.hcl to reflect new variables)
  provisioner "shell" {
    only   = ["amazon-ebs.aws-ami"]
    script = "scripts/post-install.sh"
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "USE_SUDO=sudo",
      "BUILD_TYPE=aws"
    ]
    execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }

  # QEMU/Hypervisor-Specific Post-Install Provisioner
  provisioner "shell" {
    only   = ["qemu.iso"]
    script = "scripts/post-install.sh"
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "USE_SUDO=",
      "BUILD_TYPE=qemu"
    ]
    execute_command = "echo 'ubuntu' | {{.Vars}} bash '{{.Path}}'"
  }

  # Common Provisioner for Both QEMU and AWS
  provisioner "shell" {
    scripts = [
      "scripts/provision.sh"
    ]
>>>>>>> 4f9b5dd (updated AWS to use a unified provison.sh script)
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
<<<<<<< HEAD
      "USE_SUDO=sudo",
      "BUILD_TYPE=aws"
=======
>>>>>>> 391e050 (Modified ubuntu.pkr.hcl to reflect new variables)
    ]
    execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  }
<<<<<<< HEAD

  # QEMU/Hypervisor-Specific Post-Install Provisioner
  provisioner "shell" {
    only   = ["qemu.iso"]
    script = "scripts/post-install.sh"
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "USE_SUDO=",
      "BUILD_TYPE=qemu"
    ]
    execute_command = "echo 'ubuntu' | {{.Vars}} bash '{{.Path}}'"
  }

  # Common Provisioner for Both QEMU and AWS
  provisioner "shell" {
    scripts = [
      "scripts/provision.sh"
    ]
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}"
    ]
    execute_command = "echo 'ubuntu' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
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
=======
>>>>>>> 4f9b5dd (updated AWS to use a unified provison.sh script)
}
