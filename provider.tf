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
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.2.1"
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
      name    = "proxmox-4"
      address = "10.80.100.24"
    }
    node {
      name    = "proxmox-5"
      address = "10.80.100.25"
    }
    node {
      name    = "proxmox-6"
      address = "10.80.100.26"
    }
  }
}

provider "dns" {
  update {
    server        = var.dns_server_address
    key_name      = var.dns_key_name
    key_algorithm = var.dns_key_algorithm
    key_secret    = var.dns_key_secret
  }
}

provider "terracurl" {}


