variable "vm_account_username" {
  type        = string
  description = "Username for VMs"
}

variable "vm_account_password" {
  type        = string
  description = "Password for VMs"
}

variable "docker_hosts" {
  type        = set(string)
  description = "List of hostnames for docker installation"
}
