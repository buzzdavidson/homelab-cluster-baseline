#===============================================================================
# Configuration for core DNS entries
#
# Prerequisites:
#   1. Proxmox nodes configured with static IPs (new installation)
#   3. NFS storage set up in FreeNAS
#   4. ACME set up in proxmox datacenter
#   5. ACME certificates configured for every node (proxmox-x.buzzdavidson.com)
#      - Note: can we automate this via api?
#   6. Cluster created and all nodes joined
#   7. Default linux bridge configured as vlan aware (todo: automate this)  
#
# TODO ITEMS
# [ ] - Enable gotify notifications
#       https://pve.proxmox.com/pve-docs/chapter-notifications.html
# [ ] - Configure HA groups and rules for core (will need to do the same for rancher) 
#       https://pve.proxmox.com/pve-docs/chapter-ha-manager.html
# [ ] - Enable monitoring
# [x] - Ensure time synchronization properly configured
#       https://pve.proxmox.com/pve-docs/pve-admin-guide.html
# [ ] - Configure backups
# [ ] - Add proxmox management network as second interface
# [ ] - Update nfs-flash storage to support snippets 
#
# MISC STUFF
# set tags for VM: qm set ID --tags myfirsttag;mysecondtag
# set tag apperarance: pvesh set /cluster/options --tag-style color-map=example:000000:FFFFFF
# create cluster: pvecm create CLUSTERNAME
# view cluster status: pvecm status
# add node to cluster: from node to be added: pvecm add ciuster-ip-address
#==================================================================================================

resource "dns_a_record_set" "proxmox-dns" {
  for_each = var.proxmox_servers
  zone     = "buzzdavidson.com."
  name     = each.key
  addresses = [
    each.value
  ]
}

# NOTE: If we're using vlan aware bridges, the guest can specify the vlan_id directly
# Externalizing these allow for more generic VMs to be created but creates additional management overhead
#
# TODO: If we want to create specific bridges for different VLANs, then use for loop to create all the VLANs:
# resource "proxmox_virtual_environment_network_linux_vlan" "core_services_vlan_1" {
#   node_name  = "proxmox-1"
#   name       = "vmbr0.100"
#   depends_on = [proxmox_virtual_environment_file.cloud_config]
#   comment    = "Managed by Terraform"
# }

