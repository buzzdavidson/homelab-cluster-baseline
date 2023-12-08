resource "proxmox_virtual_environment_pool" "operations_pool" {
  comment = "Managed by Terraform"
  pool_id = "operations-pool"
}

resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "nfs-flash"
  node_name    = "pve-04"
  source_file {
    path = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
  }
}

resource "proxmox_virtual_environment_vm" "dns_host_template" {
  vm_id       = 10000
  name        = "dns-host-template"
  node_name   = "pve-04"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu", "coreservices"]
  pool_id     = proxmox_virtual_environment_pool.operations_pool.id
  template    = true  # Create a VM template
  reboot      = false # Rebooting is problematic before qemu-guest-agent is installed
  started     = false # Don't start the VM, we want a clean system to clone from
  agent {
    enabled = false # Don't mark this as enabled, causes long waits in provider
  }
  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }
  memory {
    dedicated = 1024
  }
  startup {
    order      = "1"
    up_delay   = "10"
    down_delay = "10"
  }
  disk {
    datastore_id = "nfs-flash"
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
  }
  initialization {
    datastore_id = "nfs-flash"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.vm_account_username
      password = var.vm_account_password
      keys     = [var.cluster_public_key]
    }
  }
  network_device {
    bridge  = "vmbr0"
    vlan_id = 100
  }
  operating_system {
    type = "l26"
  }
  serial_device {}
}

resource "proxmox_virtual_environment_vm" "dns_01" {
  vm_id       = 10004
  name        = "core-dns-01"
  node_name   = "pve-04"
  description = "Managed by Terraform"
  pool_id     = proxmox_virtual_environment_pool.operations_pool.id
  reboot      = false # Rebooting is problematic before qemu-guest-agent is installed
  started     = true  # We want to start the VM so cloud-init can do its thing
  clone {
    full  = true
    vm_id = proxmox_virtual_environment_vm.dns_host_template.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "10.100.100.4/24"
        gateway = "10.100.100.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "dns_02" {
  vm_id       = 10005
  name        = "core-dns-02"
  node_name   = "pve-04"
  description = "Managed by Terraform"
  pool_id     = proxmox_virtual_environment_pool.operations_pool.id
  reboot      = false # Rebooting is problematic before qemu-guest-agent is installed
  started     = true  # We want to start the VM so cloud-init can do its thing
  clone {
    full  = true
    vm_id = proxmox_virtual_environment_vm.dns_host_template.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "10.100.100.5/24"
        gateway = "10.100.100.1"
      }
    }
  }
}
