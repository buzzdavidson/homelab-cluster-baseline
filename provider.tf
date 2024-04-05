terraform {
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.51.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }

  }
}

provider "proxmox" {
  alias    = "bpg"
  endpoint = var.proxmox_api_url
  #api_token = var.proxmox_api_key
  username = "root@pam"
  password = var.proxmox_ssh_password
  ssh {
    username = var.proxmox_ssh_username
    password = var.proxmox_ssh_password
    node {
      name    = "proxmox-1"
      address = "10.80.100.21"
    }
    node {
      name    = "proxmox-2"
      address = "10.80.100.22"
    }
    node {
      name    = "proxmox-3"
      address = "10.80.100.23"
    }

  }
}

provider "truenas" {
  api_key  = var.truenas_api_key
  base_url = var.truenas_api_url
}

provider "dns" {
  update {
    server        = var.dns_server_address
    key_name      = var.dns_key_name
    key_algorithm = var.dns_key_algorithm
    key_secret    = var.dns_key_secret
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
  insecure    = true
}

provider "kubectl" {
  config_path = var.kubeconfig_path
}

