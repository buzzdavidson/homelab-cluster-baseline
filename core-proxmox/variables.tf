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

variable "proxmox_servers" {
  type = map(string)
  default = {
    proxmox-1 = "10.80.100.21",
    proxmox-2 = "10.80.100.22",
    proxmox-3 = "10.80.100.23",
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
