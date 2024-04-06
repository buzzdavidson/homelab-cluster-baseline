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

module "rancher-k3s-install" {
  source     = "./rancher-k3s-install"
  depends_on = [module.rancher-k3s-proxmox-config]
}

module "rancher-cert-mgr-install" {
  source     = "./rancher-cert-mgr-install"
  depends_on = [module.rancher-k3s-install]
  providers = {
    dns        = dns
    helm       = helm
    kubernetes = kubernetes
    kubectl    = kubectl
  }
  letsencrypt_email    = var.letsencrypt_email
  cloudflare_api_token = var.cloudflare_api_token
}

# module "rancher-cert-manager-install" {
#   source                                 = "terraform-iaac/cert-manager/kubernetes"
#   version                                = "2.6.3"
#   cluster_issuer_email                   = var.letsencrypt_email
#   cluster_issuer_name                    = "letsencrypt-prod"
#   cluster_issuer_private_key_secret_name = "letsencrypt-prod-private-key"
#   create_namespace                       = false
#   depends_on                             = [kubernetes_secret.cloudflare-token-secret]
#   solvers = [
#     {
#       dns01 = {
#         cloudflare = {
#           email = var.cloudflare_email
#           zone  = var.cloudflare_zone_id
#           apiTokenSecretRef = {
#             name = "cloudflare-token-secret"
#             key  = "cloudflare_token"
#           }
#           recursiveNameservers = [
#             "jobs.ns.cloudflare.com:53",
#             "maxine.ns.cloudflare.com:53"
#           ]
#           recursiveNameserversOnly = true
#         }
#       },
#       selector = {
#         dnsNames = ["buzzdavidson.com", "*.buzzdavidson.com"]
#       }
#     }
#   ]
#   certificates = {
#     buzzdavidson-com = {
#       common_name = "*.buzzdavidson.com"
#       dns_names   = ["buzzdavidson.com", "*.buzzdavidson.com"]
#       secret_name = "buzzdavidson-com-tls"
#     }
#   }
# }

# module "rancher-traefik-install" {
#   source     = "./rancher-traefik-install"
#   depends_on = [module.rancher-cert-manager-install]
#   providers = {
#     dns        = dns
#     helm       = helm
#     kubernetes = kubernetes
#     kubectl    = kubectl
#   }
#   traefik_dashboard_credentials = var.traefik_dashboard_credentials
# }

# module "rancher-install" {
#   source     = "./rancher-install"
#   depends_on = [module.rancher-traefik-install]
#   providers = {
#     dns        = dns
#     helm       = helm
#     kubernetes = kubernetes
#     kubectl    = kubectl
#   }
#   rancher_bootstrap_password = var.rancher_bootstrap_password
#   kubeconfig_path            = var.kubeconfig_path
#   letsencrypt_email          = var.letsencrypt_email
# }
