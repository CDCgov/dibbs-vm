// This Packer template for dibbs-vm is used to build a QEMU image for Ubuntu 24.04 server.
// It includes configurations for various required plugins and a QEMU source definition.
// The build process provisions the VM with necessary scripts and files.

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.1.0"
    }
  }
}

source "qemu" "raw" {
  vm_name = "ubuntu-2404-${var.dibbs_service}-raw-${var.dibbs_version}-${var.gitsha}.raw"
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


source "qemu" "aws" {
  vm_name = "ubuntu-2404-${var.dibbs_service}-aws-${var.dibbs_version}-${var.gitsha}.raw"
  iso_url          = "http://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum     = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  disk_image       = false
  memory           = 4096
  output_directory = "build/${var.dibbs_service}-aws-${var.dibbs_version}-${var.gitsha}"
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

build {
  name = "multi-cloud-build"
  sources = [
    "source.qemu.${var.build_type}"
  ]
  provisioner "file" {
    source      = "./jails/jail.local"
    destination = "~/jail.local"
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

  provisioner "shell" {
    only = ["qemu.aws"]
    scripts = [
      "scripts/fail2ban.sh",
      "scripts/provision.sh"
    ]
    environment_vars = [
      "DIBBS_SERVICE=${var.dibbs_service}",
      "DIBBS_VERSION=${var.dibbs_version}",
      "BUILD_TYPE=aws"
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
