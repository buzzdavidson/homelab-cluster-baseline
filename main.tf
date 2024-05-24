module "core-dns-technitium" {
  source = "./core-dns-technitium"
  providers = {
    dns = dns
  }
}

module "core-proxmox-system" {
  source                     = "./core-proxmox-system"
  depends_on                 = [module.core-dns-technitium]
  domain_ntp_server          = var.domain_ntp_server
  domain_fallback_ntp_server = var.domain_fallback_ntp_server
  ansible_inventory_content  = var.ansible_inventory_content
}

module "core-proxmox" {
  source     = "./core-proxmox"
  depends_on = [module.core-proxmox-system]
  providers = {
    proxmox = proxmox.bpg
    dns     = dns
  }
  cluster_public_key  = var.cluster_public_key
  vm_account_password = var.vm_account_password
  vm_account_username = var.vm_account_username
  proxmox_servers     = var.proxmox_servers
  proxmox_vlans       = var.proxmox_vlans
}

module "core-proxmox-virtualmachines" {
  source     = "./core-proxmox-virtualmachines"
  depends_on = [module.core-proxmox]
  providers = {
    proxmox = proxmox.bpg
    dns     = dns
  }
  cluster_public_key        = var.cluster_public_key
  cluster_private_key       = var.cluster_private_key
  vm_account_password       = var.vm_account_password
  vm_account_username       = var.vm_account_username
  proxmox_virtual_machines  = var.proxmox_virtual_machines
  proxmox_primary_node_name = var.proxmox_primary_node_name
}

module "core-docker" {
  source              = "./core-docker"
  depends_on          = [module.core-proxmox-virtualmachines]
  vm_account_password = var.vm_account_password
  vm_account_username = var.vm_account_username
  docker_hosts        = var.docker_hosts
}

module "core-portainer" {
  source                        = "./core-portainer"
  depends_on                    = [module.core-docker]
  vm_account_password           = var.vm_account_password
  vm_account_username           = var.vm_account_username
  portainer_hostname            = var.proxmox_virtual_machines["core-portainer-1"].fqdn
  portainer_ip_address          = var.proxmox_virtual_machines["core-portainer-1"].ip_address
  portainer_admin_password_hash = var.portainer_admin_password_hash
  portainer_admin_password      = var.portainer_admin_password
  portainer_version             = var.portainer_version
  portainer_openai_key          = var.portainer_openai_key
  portainer_license_key         = var.portainer_license_key
  github_access_token           = var.github_access_token
  docker_hosts                  = var.docker_hosts
  providers = {
    dns       = dns
    terracurl = terracurl
  }
}

# module "k3s-clusters" {
#   source                       = "./k3s-clusters"
#   depends_on                   = [module.core-proxmox-virtualmachines]
#   k3s_clusters                 = var.k3s_clusters
#   rancher_join_token           = var.rancher_join_token
#   buzzdavidson_home_join_token = var.buzzdavidson_home_join_token
# }
