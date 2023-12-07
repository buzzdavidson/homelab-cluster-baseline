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
  source     = "./core-proxmox-system"
  depends_on = [module.core-storage]
}

module "core-proxmox" {
  source     = "./core-proxmox"
  depends_on = [module.core-proxmox-system]
  providers = {
    proxmox = proxmox.bpg
  }
}

module "core-dns-proxmox" {
  source     = "./core-dns-proxmox"
  depends_on = [module.core-proxmox]
  providers = {
    proxmox = proxmox.bpg
  }
}

module "core-dns-config" {
  source     = "./core-dns-config"
  depends_on = [module.core-dns-proxmox]
}

# module "rancher-proxmox" {
#   source          = "./rancher-proxmox"
#   proxmox_api_key = var.proxmox_api_key
#   proxmox_api_url = "https://10.80.100.64:8006"
# }

# module "rancher-k3s" {
#   source = "./rancher-k3s"
# }

# module "rancher-helm" {
#   source = "./rancher-helm"
# }
