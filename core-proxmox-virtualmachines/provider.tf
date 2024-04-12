terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    dns = {
      source = "hashicorp/dns"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
