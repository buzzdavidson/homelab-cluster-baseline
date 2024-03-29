# module "core-network" {
#   source = "./core-network"
# }

# module "core-firewall" {
#   source = "./core-firewall"
# }

module "core-storage" {
  source = "./core-storage"
}

module "core-proxmox-system" {
  source                     = "./core-proxmox-system"
  depends_on                 = [module.core-storage]
  domain_ntp_server          = var.domain_ntp_server
  domain_fallback_ntp_server = var.domain_fallback_ntp_server
}

module "core-proxmox" {
  source     = "./core-proxmox"
  depends_on = [module.core-proxmox-system]
  providers = {
    proxmox = proxmox.bpg
  }
  cluster_public_key  = var.cluster_public_key
  vm_account_password = var.vm_account_password
  vm_account_username = var.vm_account_username
}

module "rancher-k3s-proxmox" {
  source     = "./rancher-k3s-proxmox"
  depends_on = [module.core-proxmox]
  providers = {
    proxmox = proxmox.bpg
  }
  cluster_public_key  = var.cluster_public_key
  vm_account_password = var.vm_account_password
  vm_account_username = var.vm_account_username
}

# module "core-dns-proxmox" {
#   source     = "./core-dns-proxmox"
#   depends_on = [module.core-proxmox]
#   providers = {
#     proxmox = proxmox.bpg
#   }
#   cluster_public_key  = var.cluster_public_key
#   vm_account_password = var.vm_account_password
#   vm_account_username = var.vm_account_username
# }

# module "core-dns-config" {
#   source              = "./core-dns-config"
#   depends_on          = [module.core-dns-proxmox]
#   cluster_public_key  = var.cluster_public_key
#   vm_account_username = var.vm_account_username
# }

# module "rancher-proxmox" {
#   source          = "./rancher-proxmox"
#   proxmox_api_key = var.proxmox_api_key
#   proxmox_api_url = "https://10.80.100.21:8006"
# }

# module "rancher-k3s" {
#   source = "./rancher-k3s"
# }

# module "rancher-helm" {
#   source = "./rancher-helm"
# }
