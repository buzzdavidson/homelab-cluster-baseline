resource "proxmox_virtual_environment_pool" "operations_pool" {
  comment = "Managed by Terraform"
  pool_id = "operations-pool"
}

resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve-04"

  source_file {
    path = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
  }
}

resource "proxmox_virtual_environment_file" "bind9_cloud_config" {
  # To clarify, this functionality uses SSH to connect to the host, as proxmox doesn't allow
  # programmatic access to create snippets.
  # FUTURE NOTE: because this uses SSH, the node name resolution is a bit weird.  This needs to be 
  # a DNS-resolvable FQDN for the node, not just the node name.  This is most easily configured
  # on the main provider definition.
  #
  # TODO: this doesn't work using storage nfs-flash, but does work using local storage
  #
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve-04"

  source_raw {
    data = <<EOF
#cloud-config
chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false
packages:
  - qemu-guest-agent
  - bind9
  - bind9utils
  - bind9-doc
users:
  - default
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    ssh-authorized-keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHvGD0vwY5rAR/TWkAEOmszyG45e6CLKnAYy5heBY9PQC/GgvbU7/q2ERNCClC3/wTvkyJNsloBHQwk7CabG2Y/6Glnsy6c1gbp8jl05aEupw5sFeKEzoW2GZ14AppV+2YjoZl6ufz3pgVcYI9qYzW3xzzv2tUMVCnUgoKJetL109zgA3DZontOcquRcwLmGJdmCZWbq0BSri/zSuRZ+rvAGakr0IVzPd11Iirx24xUUIXIytaDHiw5M34hlB/D9movcIJ5IFG5ezX8a5HyxPUiT0vvd5yBq+4Is0kAB5ZD0IsGP+V+iuBDcPcFi62C01IRLhuuOAw26Tfi7Wr2y37"
    sudo: ALL=(ALL) NOPASSWD:ALL
EOF

    file_name = "ubuntu2204.bind9-cloud-config.yaml"
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
    enabled = true
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
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.bind9_cloud_config.id
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
  #  tags        = ["terraform", "ubuntu", "coreservices"]
  #  pool_id     = proxmox_virtual_environment_pool.operations_pool.id
  #  template    = true
  reboot  = true
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
  #  tags        = ["terraform", "ubuntu", "coreservices"]
  #  pool_id     = proxmox_virtual_environment_pool.operations_pool.id
  #  template    = true
  reboot  = true
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
