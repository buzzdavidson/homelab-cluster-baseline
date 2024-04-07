variable "cloudflare_email" {
  type        = string
  description = "Email address for Cloudflare"
  sensitive   = true
}

variable "cloudflare_api_token" {
  type        = string
  description = "API Token for Cloudflare"
  sensitive   = true
}

variable "dns_server_address" {
  type        = string
  description = "IP Address of DNS server for updates"
  default     = "10.40.100.150"
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

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address for Let's Encrypt"
  sensitive   = true
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

variable "rancher_bootstrap_password" {
  type        = string
  sensitive   = true
  description = "Bootstrap password for Rancher"
}

variable "rancher_k3s_join_token" {
  type        = string
  sensitive   = false
  description = "Join token for Rancher"
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
  default     = "10.0.0.1"
}

variable "domain_fallback_ntp_server" {
  type        = string
  description = "Fallback NTP server for domain"
  default     = "time.cloudflare.com"
}

variable "traefik_dashboard_credentials" {
  type        = string
  sensitive   = true
  description = "Password for Traefik dashboard"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID for Cloudflare"
  sensitive   = true
}
