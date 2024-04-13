#===============================================================================
# Configuration for core virtual machines
#
#===============================================================================

resource "proxmox_virtual_environment_file" "k3s_cloud_config" {
  content_type = "snippets"
  datastore_id = "nfs-flash"
  node_name    = "proxmox-1"

  source_raw {
    data = <<EOF
#cloud-config
preserve_hostname: false
users:
  - default
  - name: ubuntu
    passwd: ${var.vm_account_password}
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
  depends_on   = [proxmox_virtual_environment_file.k3s_cloud_config]
  content_type = "iso"
  datastore_id = "nfs-flash"
  node_name    = "proxmox-1"
  url          = "https://cloud-images.ubuntu.com/jammy/20240403/jammy-server-cloudimg-amd64-disk-kvm.img"
  overwrite    = true
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "proxmox_virtual_environment_vm" "rancher_k3s_hosts" {
  depends_on  = [proxmox_virtual_environment_download_file.ubuntu_cloud_image]
  for_each    = var.proxmox_virtual_machines
  name        = each.value.fqdn
  node_name   = each.value.proxmox_node
  description = "Managed by Terraform"
  tags        = each.value.tags
  reboot      = true
  started     = true
  agent {
    enabled = true
  }
  cpu {
    cores   = each.value.cpu_cores
    sockets = 1
    type    = "x86-64-v2-AES"
  }
  memory {
    dedicated = each.value.memory
  }
  # startup {
  #   order      = "1"
  #   up_delay   = "0"
  #   down_delay = "0"
  # }
  disk {
    datastore_id = each.value.datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = each.value.disk_interface
    iothread     = true
    discard      = "on"
    size         = each.value.disk_size_gb
  }
  initialization {
    # This is the datastore for the cloud-init drive
    datastore_id = each.value.datastore_id
    ip_config {
      ipv4 {
        address = "${each.value.ip_address}/24"
        gateway = each.value.gateway_address
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
    bridge  = each.value.network_bridge
    vlan_id = each.value.vlan_id
  }
  operating_system {
    type = "l26"
  }
}

resource "dns_a_record_set" "proxmox-dns" {
  depends_on = [proxmox_virtual_environment_vm.rancher_k3s_hosts]
  for_each   = var.proxmox_virtual_machines
  zone       = "buzzdavidson.com."
  name       = each.key
  addresses = [
    each.value.ip_address
  ]
}

# k3s install doesn't like it when the hostname is not set properly; make sure each VM has the correct hostname
resource "null_resource" "update_hostnames" {
  depends_on = [dns_a_record_set.proxmox-dns]
  for_each   = var.proxmox_virtual_machines
  triggers = {
    fqdn = each.value.fqdn
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value.ip_address
      user        = var.vm_account_username
      password    = var.vm_account_password
      agent       = false
      private_key = file("~/.ssh/id_cluster_rsa")
    }
    inline = [
      "sudo hostnamectl set-hostname ${each.value.fqdn}",
      "sudo hostname -F /etc/hostname",
      "sudo systemctl restart systemd-hostnamed",
    ]
  }
}

