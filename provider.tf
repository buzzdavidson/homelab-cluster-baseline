terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.39.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }

  }
}

provider "proxmox" {
  alias     = "bpg"
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_key
  ssh {
    username = var.proxmox_ssh_username
    password = var.proxmox_ssh_password
    node {
      name    = "pve-04"
      address = "10.80.100.64"
    }
    node {
      name    = "pve-05"
      address = "10.80.100.65"
    }
    node {
      name    = "pve-10"
      address = "10.80.100.70"
    }

  }
}

provider "truenas" {
  api_key  = var.truenas_api_key
  base_url = var.truenas_api_url
}



