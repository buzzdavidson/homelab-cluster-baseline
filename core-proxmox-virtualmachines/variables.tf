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
}

variable "cluster_private_key" {
  type        = string
  description = "Private key for SSH access to VMs"
  sensitive   = true
}


variable "cluster_public_key" {
  type        = string
  description = "Public key for cluster access"
}

variable "vm_account_username" {
  type        = string
  description = "Username for VMs"
}

variable "vm_account_password" {
  type        = string
  description = "Password for VMs"
}

variable "proxmox_primary_node_name" {
  type        = string
  description = "Name of the primary Proxmox node"
}

