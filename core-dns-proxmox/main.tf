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
  template    = true
  reboot      = false
  started     = false

  agent {
    enabled = false
  }
  audio_device {
    enabled = false
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
      username = "ubuntu"
      password = "ubuntu"
      keys     = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHvGD0vwY5rAR/TWkAEOmszyG45e6CLKnAYy5heBY9PQC/GgvbU7/q2ERNCClC3/wTvkyJNsloBHQwk7CabG2Y/6Glnsy6c1gbp8jl05aEupw5sFeKEzoW2GZ14AppV+2YjoZl6ufz3pgVcYI9qYzW3xzzv2tUMVCnUgoKJetL109zgA3DZontOcquRcwLmGJdmCZWbq0BSri/zSuRZ+rvAGakr0IVzPd11Iirx24xUUIXIytaDHiw5M34hlB/D9movcIJ5IFG5ezX8a5HyxPUiT0vvd5yBq+4Is0kAB5ZD0IsGP+V+iuBDcPcFi62C01IRLhuuOAw26Tfi7Wr2y37"]
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
  #reboot      = true
  started = true
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
  #reboot      = true
  started = true
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
