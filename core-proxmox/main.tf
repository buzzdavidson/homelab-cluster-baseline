# NOTE: this requires some manual set-up first!
# 1. Proxmox nodes configured with static IPs (new installation)
# 3. NFS storage set up in FreeNAS
# 4. ACME set up in proxmox datacenter
# 5. ACME certificates configured for every node (proxmox-x.buzzdavidson.com)
#    Note: can we automate this via api?
# 6. New API token created for root user
# 7. New API token granted access to all storage (config in datacenter for each node)
# 8. Cluster created and all nodes joined

#==================================================================================================
# TODO ITEMS
# [ ] - Enable gotify notifications
#       https://pve.proxmox.com/pve-docs/chapter-notifications.html
# [ ] - Configure HA groups and rules for core (will need to do the same for rancher) 
#       https://pve.proxmox.com/pve-docs/chapter-ha-manager.html
# [ ] - Enable monitoring
# [ ] - Ensure time synchronization properly configured
#       https://pve.proxmox.com/pve-docs/pve-admin-guide.html
# [ ] - Configure backups
# [ ] - Add proxmox management network as second interface
# [ ] - Update local storage to support snippets
#
# MISC STUFF
# set tags for VM: qm set ID --tags myfirsttag;mysecondtag
# set tag apperarance: pvesh set /cluster/options --tag-style color-map=example:000000:FFFFFF
# create cluster: pvecm create CLUSTERNAME
# view cluster status: pvecm status
# add node to cluster: from node to be added: pvecm add ciuster-ip-address
#==================================================================================================
resource "proxmox_virtual_environment_file" "cloud_config" {
  # To clarify, this functionality uses SSH to connect to the host, as proxmox doesn't allow
  # programmatic access to create snippets.
  # FUTURE NOTE: because this uses SSH, the node name resolution is a bit weird.  This needs to be 
  # a DNS-resolvable FQDN for the node, not just the node name.  This is most easily configured
  # on the main provider definition.
  #
  # TODO: this doesn't work using storage nfs-flash, but does work using local storage
  #
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox-1"

  source_raw {
    data = <<EOF
#cloud-config
chpasswd:
  list: |
    ${var.vm_account_username}:${var.vm_account_password}
  expire: false
packages:
  - qemu-guest-agent
users:
  - default
  - name: ${var.vm_account_username}
    groups: sudo
    shell: /bin/bash
    ssh-authorized-keys:
      - "${var.cluster_public_key}"
    sudo: ALL=(ALL) NOPASSWD:ALL
EOF

    file_name = "ubuntu2204.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_network_linux_vlan" "core_services_vlan_1" {
  node_name = "proxmox-1"
  name      = "vmbr0.100"

  comment = "Managed by Terraform"
}

resource "proxmox_virtual_environment_network_linux_vlan" "core_services_vlan_2" {
  node_name = "proxmox-2"
  name      = "vmbr0.100"

  comment = "Managed by Terraform"
}

resource "proxmox_virtual_environment_network_linux_vlan" "core_services_vlan_3" {
  node_name = "proxmox-3"
  name      = "vmbr0.100"

  comment = "Managed by Terraform"
}
