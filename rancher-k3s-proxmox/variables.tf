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

variable "rancher_k3s_servers" {
  type = map(string)
  default = {
    rancher-k3s-1 = "10.10.100.11",
    rancher-k3s-2 = "10.10.100.12",
    rancher-k3s-3 = "10.10.100.13",
  }
}
