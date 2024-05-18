variable "vm_account_username" {
  type        = string
  description = "Username for VMs"
}

variable "vm_account_password" {
  type        = string
  description = "Password for VMs"
}

variable "portainer_hostname" {
  type        = string
  description = "Hostname of the Portainer VM"
}

variable "portainer_ip_address" {
  type        = string
  description = "IP Address of the Portainer VM"
}

variable "portainer_admin_password_hash" {
  type        = string
  description = "Password for the Portainer admin user"
  sensitive   = true
}

variable "docker_hosts" {
  type        = set(string)
  description = "List of hostnames for docker installation"
}

variable "portainer_version" {
  type        = string
  description = "Version of Portainer to install"
}

