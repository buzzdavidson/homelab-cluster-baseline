terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.50.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
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



