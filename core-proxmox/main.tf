# NOTE: this requires some manual set-up first!
# 1. Proxmox nodes configured with static IPs (new installation)
# 3. NFS storage set up in FreeNAS
# 4. ACME set up in proxmox datacenter
# 5. ACME certificates configured for every node
# 6. New API token created for root user
# 7. New API token granted access to all storage (config in datacenter for each node)
# 8. Cluster created and all nodes joined
resource "proxmox_virtual_environment_file" "ubuntu_container_template" {
  content_type = "iso"
  datastore_id = "nfs-flash"
  node_name    = "pve-04"

  source_file {
    path = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
  }
}

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
  node_name    = "pve-04"

  source_raw {
    data = <<EOF
#cloud-config
chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false
hostname: example-hostname
packages:
  - qemu-guest-agent
users:
  - default
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    ssh-authorized-keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHvGD0vwY5rAR/TWkAEOmszyG45e6CLKnAYy5heBY9PQC/GgvbU7/q2ERNCClC3/wTvkyJNsloBHQwk7CabG2Y/6Glnsy6c1gbp8jl05aEupw5sFeKEzoW2GZ14AppV+2YjoZl6ufz3pgVcYI9qYzW3xzzv2tUMVCnUgoKJetL109zgA3DZontOcquRcwLmGJdmCZWbq0BSri/zSuRZ+rvAGakr0IVzPd11Iirx24xUUIXIytaDHiw5M34hlB/D9movcIJ5IFG5ezX8a5HyxPUiT0vvd5yBq+4Is0kAB5ZD0IsGP+V+iuBDcPcFi62C01IRLhuuOAw26Tfi7Wr2y37"
    sudo: ALL=(ALL) NOPASSWD:ALL
EOF

    file_name = "ubuntu2204.cloud-config.yaml"
  }
}