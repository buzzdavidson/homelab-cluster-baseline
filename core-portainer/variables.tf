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

variable "portainer_admin_password" {
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

variable "portainer_openai_key" {
  type        = string
  description = "OpenAI key for Portainer"
  sensitive   = true
}

variable "github_access_token" {
  type        = string
  description = "GitHub access token for API access"
  sensitive   = true
}

variable "portainer_license_key" {
  type        = string
  description = "License key for Portainer"
  sensitive   = true
}



