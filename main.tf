module "core-storage" {
  source = "./core-storage"
}

module "core-dns-technitium" {
  source     = "./core-dns-technitium"
  depends_on = [module.core-storage]
  providers = {
    dns = dns
  }
}

module "core-proxmox-system" {
  source                     = "./core-proxmox-system"
  depends_on                 = [module.core-dns-technitium]
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
    dns     = dns
  }
  cluster_public_key  = var.cluster_public_key
  vm_account_password = var.vm_account_password
  vm_account_username = var.vm_account_username
}

module "rancher-k3s-proxmox-config" {
  source                     = "./rancher-k3s-proxmox-config"
  depends_on                 = [module.rancher-k3s-proxmox]
  domain_ntp_server          = var.domain_ntp_server
  domain_fallback_ntp_server = var.domain_fallback_ntp_server
}
