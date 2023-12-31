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

variable "domain_ntp_server" {
  type        = string
  description = "NTP server for domain"
  default = "10.0.0.1"
}

variable "domain_fallback_ntp_server" {
  type        = string
  description = "Fallback NTP server for domain"
  default = "time.cloudflare.com"
}

variable "vlans" {
  type = list(object({
    vlan_id   = number
    vlan_name = string
  }))
  default = [
    {
      vlan_id   = 10
      vlan_name = "home"
    },
    {
      vlan_id   = 22
      vlan_name = "lab"
    },
    {
      vlan_id   = 40
      vlan_name = "storage"
    },
    {
      vlan_id   = 66
      vlan_name = "management"
    },
    {
      vlan_id   = 72
      vlan_name = "ipmi"
    },
    {
      vlan_id   = 80
      vlan_name = "proxmox_host"
    },
    {
      vlan_id   = 99
      vlan_name = "gizmo"
    },

  ]
}
