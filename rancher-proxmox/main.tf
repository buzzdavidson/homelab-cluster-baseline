resource "proxmox_virtual_environment_pool" "rancher_pool" {
  comment = "Managed by Terraform"
  pool_id = "rancher-pool"
}

