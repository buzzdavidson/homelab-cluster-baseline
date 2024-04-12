variable "cluster_public_key" {
  type        = string
  description = "Public key for cluster access"
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

variable "truenas_api_key" {
  type        = string
  sensitive   = true
  description = "API Key for programmatic access to TrueNAS"
}

variable "truenas_api_url" {
  type        = string
  description = "Base URL for TrueNAS API"
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
      datastore_id    = "local-lvm"
      disk_interface  = "virtio0"
      disk_size_gb    = 30
      fqdn            = "home-portainer-1.buzzdavidson.com"
      gateway_address = "10.160.100.1"
      ip_address      = "10.160.100.69"
      memory          = 8192
      network_bridge  = "vmbr0"
      proxmox_node    = "proxmox-4"
      tags            = ["terraform", "ubuntu", "portainer", "home"]
      vlan_id         = 160
    },
    # "home-k3s-1" = {
    #   cpu_cores       = 4
    #   datastore_id    = "local-lvm"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 10
    #   fqdn            = "home-k3s-1.buzzdavidson.com"
    #   gateway_address = "10.160.100.1"
    #   ip_address      = "10.160.100.21"
    #   memory          = 8192
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-4"
    #   tags            = ["terraform", "ubuntu", "k3s", "home"]
    #   vlan_id         = 160
    # },
    # "home-k3s-2" = {
    #   cpu_cores       = 4
    #   datastore_id    = "local-lvm"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 10
    #   fqdn            = "home-k3s-2.buzzdavidson.com"
    #   gateway_address = "10.160.100.1"
    #   ip_address      = "10.160.100.22"
    #   memory          = 8192
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-5"
    #   tags            = ["terraform", "ubuntu", "k3s", "home"]
    #   vlan_id         = 160
    # },
    # "home-k3s-3" = {
    #   cpu_cores       = 4
    #   datastore_id    = "local-lvm"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 10
    #   fqdn            = "home-k3s-3.buzzdavidson.com"
    #   gateway_address = "10.160.100.1"
    #   ip_address      = "10.160.100.23"
    #   memory          = 8192
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-6"
    #   tags            = ["terraform", "ubuntu", "k3s", "home"]
    #   vlan_id         = 160
    # },
    # "rancher-k3s-1" = {
    #   cpu_cores       = 2
    #   datastore_id    = "local-lvm"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 10
    #   fqdn            = "rancher-k3s-1.buzzdavidson.com"
    #   gateway_address = "10.100.100.1"
    #   ip_address      = "10.100.100.21"
    #   memory          = 8192
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-1"
    #   proxmox_node    = "proxmox-1"
    #   tags            = ["terraform", "ubuntu", "k3s", "rancher"]
    #   vlan_id         = 100
    # },
    # "rancher-k3s-2" = {
    #   cpu_cores       = 2
    #   datastore_id    = "local-lvm"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 10
    #   fqdn            = "rancher-k3s-2.buzzdavidson.com"
    #   gateway_address = "10.100.100.1"
    #   ip_address      = "10.100.100.22"
    #   memory          = 8192
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-2"
    #   tags            = ["terraform", "ubuntu", "k3s", "rancher"]
    #   vlan_id         = 100
    # },
    # "rancher-k3s-3" = {
    #   cpu_cores       = 2
    #   datastore_id    = "local-lvm"
    #   disk_interface  = "virtio0"
    #   disk_size_gb    = 10
    #   fqdn            = "rancher-k3s-3.buzzdavidson.com"
    #   gateway_address = "10.100.100.1"
    #   ip_address      = "10.100.100.23"
    #   memory          = 8192
    #   network_bridge  = "vmbr0"
    #   proxmox_node    = "proxmox-3"
    #   tags            = ["terraform", "ubuntu", "k3s", "rancher"]
    #   vlan_id         = 100
    # },

  }
}
