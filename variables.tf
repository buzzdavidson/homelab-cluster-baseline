variable "cluster_public_key" {
  type        = string
  description = "Public key for cluster access"
  sensitive   = true
}

variable "cluster_private_key" {
  type        = string
  description = "Private key for SSH access to VMs"
  sensitive   = true
}

variable "dns_key_algorithm" {
  type        = string
  description = "Algorithm for DNS key"
  sensitive   = true
}

variable "dns_key_name" {
  type        = string
  description = "Name of the key for DNS updates"
  sensitive   = true
}

variable "dns_key_secret" {
  type        = string
  description = "Shared secret for DNS updates"
  sensitive   = true
}

variable "dns_server_address" {
  type        = string
  description = "IP Address of DNS server for updates"
  default     = "10.40.100.150"
}

variable "proxmox_api_key" {
  type        = string
  sensitive   = true
  description = "API Key for programmatic access to proxmox"
}

variable "proxmox_api_url" {
  type        = string
  description = "API Key for programmatic access to proxmox"
}

variable "proxmox_ssh_password" {
  type        = string
  sensitive   = true
  description = "SSH Password for programmatic access to proxmox"
}

variable "proxmox_ssh_username" {
  type        = string
  sensitive   = true
  description = "SSH Username for programmatic access to proxmox"
}

variable "vm_account_username" {
  type        = string
  description = "Username for VMs"
}

variable "vm_account_password" {
  type        = string
  description = "Password for VMs"
}

variable "domain_ntp_server" {
  type        = string
  description = "NTP server for domain"
  default     = "10.0.0.1"
}

variable "domain_fallback_ntp_server" {
  type        = string
  description = "Fallback NTP server for domain"
  default     = "time.cloudflare.com"
}

variable "proxmox_virtual_machines" {
  type = map(object({
    fqdn            = string
    tags            = list(string)
    cpu_cores       = number
    memory          = number
    datastore_id    = string
    ip_address      = string
    gateway_address = string
    proxmox_node    = string
    vlan_id         = number
    disk_size_gb    = number
    disk_interface  = string
    network_bridge  = string
  }))
  default = {
    "home-portainer-1" = {
      cpu_cores       = 4
      datastore_id    = "nfs-flash"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "home-portainer-1.buzzdavidson.com"
      gateway_address = "10.160.100.1"
      ip_address      = "10.160.100.69"
      memory          = 4096
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-4"
      tags            = ["terraform", "home", "portainer"]
      vlan_id         = 160
    },
    "home-docker-1" = {
      cpu_cores       = 8
      datastore_id    = "nfs-flash"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "home-docker-1.buzzdavidson.com"
      gateway_address = "10.160.100.1"
      ip_address      = "10.160.100.70"
      memory          = 8192
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-5"
      tags            = ["terraform", "home", "docker"]
      vlan_id         = 160
    },
    # "core-docker-1" = {
    #   cpu_cores       = 4
    #   datastore_id    = "nfs-flash"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 30
    #   fqdn            = "core-docker-1.buzzdavidson.com"
    #   gateway_address = "10.160.100.1"
    #   ip_address      = "10.160.100.72"
    #   memory          = 4096
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-6"
    #   tags            = ["terraform", "core", "docker"]
    #   vlan_id         = 160
    # },
    "home-k3s-1" = {
      cpu_cores       = 4
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "home-k3s-1.buzzdavidson.com"
      gateway_address = "10.160.100.1"
      ip_address      = "10.160.100.21"
      memory          = 8192
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-4"
      tags            = ["terraform", "home", "k3s"]
      vlan_id         = 160
    },
    "home-k3s-2" = {
      cpu_cores       = 4
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "home-k3s-2.buzzdavidson.com"
      gateway_address = "10.160.100.1"
      ip_address      = "10.160.100.22"
      memory          = 8192
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-5"
      tags            = ["terraform", "home", "k3s"]
      vlan_id         = 160
    },
    "home-k3s-3" = {
      cpu_cores       = 4
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "home-k3s-3.buzzdavidson.com"
      gateway_address = "10.160.100.1"
      ip_address      = "10.160.100.23"
      memory          = 8192
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-6"
      tags            = ["terraform", "home", "k3s"]
      vlan_id         = 160
    },
    "rancher-k3s-1" = {
      cpu_cores       = 4
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "rancher-k3s-1.buzzdavidson.com"
      gateway_address = "10.100.100.1"
      ip_address      = "10.100.100.21"
      memory          = 4096
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-4"
      tags            = ["terraform", "rancher", "k3s"]
      vlan_id         = 100
    },
    "rancher-k3s-2" = {
      cpu_cores       = 4
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "rancher-k3s-2.buzzdavidson.com"
      gateway_address = "10.100.100.1"
      ip_address      = "10.100.100.22"
      memory          = 4096
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-5"
      tags            = ["terraform", "rancher", "k3s"]
      vlan_id         = 100
    },
    "rancher-k3s-3" = {
      cpu_cores       = 4
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "rancher-k3s-3.buzzdavidson.com"
      gateway_address = "10.100.100.1"
      ip_address      = "10.100.100.23"
      memory          = 4096
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-6"
      tags            = ["terraform", "rancher", "k3s"]
      vlan_id         = 100
    },
    "harvester-witness" = {
      cpu_cores       = 2
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 10
      fqdn            = "harvester-witness.buzzdavidson.com"
      gateway_address = "10.140.100.1"
      ip_address      = "10.140.100.66"
      memory          = 2048
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-6"
      tags            = ["terraform", "harvester"]
      vlan_id         = 140
    },

  }
}

variable "proxmox_servers" {
  type = map(string)
  default = {
    proxmox-4 = "10.80.100.24",
    proxmox-5 = "10.80.100.25",
    proxmox-6 = "10.80.100.26",
  }
}

variable "proxmox_vlans" {
  type = map(number)
  default = {
    core_services_vlan     = 100,
    harvester_vlan         = 140,
    buzzdavidson_home_vlan = 160
  }
}


variable "portainer_hostname" {
  type        = string
  description = "Hostname of the Portainer VM"
  default     = "home-portainer-1.buzzdavidson.com"
}

variable "portainer_license_key" {
  type        = string
  description = "License key for Portainer"
  sensitive   = true
}

variable "portainer_ops_token" {
  type        = string
  description = "Ops token for Portainer"
  sensitive   = true
}

variable "portainer_admin_password_hash" {
  type        = string
  description = "Hashed password for the Portainer admin user"
  sensitive   = true
}

variable "buzzdavidson_home_join_token" {
  type        = string
  description = "Join token for the buzzdavidson-home k3s cluster"
}

variable "rancher_join_token" {
  type        = string
  description = "join token for the rancher k3s cluster"
}

variable "k3s_clusters" {
  type = map(object({
    apiserver_endpoint = string
    metal_lb_ip_range  = string
  }))
  default = {
    "buzzdavidson-home" = {
      apiserver_endpoint = "10.160.100.100"
      metal_lb_ip_range  = "10.160.100.125-10.160.100.199"
    },
    "rancher" = {
      apiserver_endpoint = "10.100.100.100"
      metal_lb_ip_range  = "10.100.100.125-10.100.100.199"
    },

  }
}

variable "ansible_inventory_content" {
  type    = string
  default = <<EOF
[core_proxmox_hosts]
10.80.100.24
10.80.100.25
10.80.100.26

[core_proxmox_hosts:vars]
ansible_user=root
EOF
}

variable "proxmox_primary_node_name" {
  type        = string
  description = "Name of the primary Proxmox node"
  default     = "proxmox-4"
}

variable "docker_hosts" {
  type        = set(string)
  description = "List of hostnames for docker installation"
  default     = ["home-portainer-1.buzzdavidson.com", "home-docker-1.buzzdavidson.com"]
}

variable "portainer_version" {
  type        = string
  description = "Version of Portainer to install"
  default     = "2.20.2"
}





