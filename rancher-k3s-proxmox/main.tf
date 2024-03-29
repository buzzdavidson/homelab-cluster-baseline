resource "proxmox_virtual_environment_pool" "rancher_pool" {
  comment = "Managed by Terraform"
  pool_id = "rancher-pool"
}

resource "proxmox_virtual_environment_file" "k3s_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox-1"

  source_raw {
    data = <<EOF
#cloud-config
users:
  - default
  - name: ubuntu
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${trimspace(var.cluster_public_key)}
    sudo: ALL=(ALL) NOPASSWD:ALL
runcmd:
    - apt update
    - apt install -y qemu-guest-agent net-tools
    - timedatectl set-timezone America/Los_Angeles
    - systemctl enable qemu-guest-agent
    - systemctl start qemu-guest-agent
    - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "nfs-flash"
  node_name    = "proxmox-1"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
  overwrite    = true
}

resource "proxmox_virtual_environment_vm" "k3s_host_template" {
  vm_id       = 12010
  name        = "k3s-host-template"
  node_name   = "proxmox-1"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu", "rancher"]
  pool_id     = proxmox_virtual_environment_pool.rancher_pool.id
  template    = true  # Create a VM template
  reboot      = false # Rebooting is problematic before qemu-guest-agent is installed
  started     = false # Don't start the VM, we want a clean system to clone from
  agent {
    enabled = false # Don't mark this as enabled, causes long waits in provider
  }
  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }
  memory {
    dedicated = 4096
  }
  startup {
    order      = "1"
    up_delay   = "0"
    down_delay = "0"
  }
  disk {
    datastore_id = "nfs-flash"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
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
      keys     = ["${trimspace(var.cluster_public_key)}"]
    }
    user_data_file_id = proxmox_virtual_environment_file.k3s_cloud_config.id
  }
  network_device {
    bridge  = "vmbr0"
    vlan_id = 100
  }
  operating_system {
    type = "l26"
  }
}


resource "proxmox_virtual_environment_vm" "rancher_k3s_1" {
  vm_id       = 12861
  name        = "rancher-k3s-1"
  node_name   = "proxmox-1"
  description = "Managed by Terraform"
  pool_id     = proxmox_virtual_environment_pool.rancher_pool.id
  reboot      = true
  started     = true
  clone {
    full  = true
    vm_id = proxmox_virtual_environment_vm.k3s_host_template.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "10.100.100.11/24"
        gateway = "10.100.100.1"
      }
    }
  }
  agent {
    enabled = true
  }
}

resource "proxmox_virtual_environment_vm" "rancher_k3s_2" {
  vm_id       = 12862
  name        = "rancher-k3s-2"
  node_name   = "proxmox-1"
  description = "Managed by Terraform"
  pool_id     = proxmox_virtual_environment_pool.rancher_pool.id
  reboot      = true
  started     = true
  clone {
    full  = true
    vm_id = proxmox_virtual_environment_vm.k3s_host_template.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "10.100.100.12/24"
        gateway = "10.100.100.1"
      }
    }
  }
  agent {
    enabled = true
  }
}

resource "proxmox_virtual_environment_vm" "rancher_k3s_3" {
  vm_id       = 12863
  name        = "rancher-k3s-3"
  node_name   = "proxmox-1"
  description = "Managed by Terraform"
  pool_id     = proxmox_virtual_environment_pool.rancher_pool.id
  reboot      = true
  started     = true
  clone {
    full  = true
    vm_id = proxmox_virtual_environment_vm.k3s_host_template.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "10.100.100.13/24"
        gateway = "10.100.100.1"
      }
    }
  }
  agent {
    enabled = true
  }
}

resource "null_resource" "delay" {
  # This is a hack to allow the VMs to start up and get their IP addresses before we run the Ansible script
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [proxmox_virtual_environment_vm.rancher_k3s_1, proxmox_virtual_environment_vm.rancher_k3s_2, proxmox_virtual_environment_vm.rancher_k3s_3]
}

# TODO: add dns entries for new hosts
# TODO: migrate host 2 and 3 to proper proxmox nodes
# TODO: for each host, add a second network interface for the rancher network
# TODO: for each host, turn on guest agent
# TODO: delete k3s_host_template after execution

