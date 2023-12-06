# Note: NFS share creation is currently broken due to API cnahges in TrueNAS 22.12.0
# errors: "alldirs" attribute not expected, "paths" removed and replaced with "path"
# https://github.com/dariusbakunas/terraform-provider-truenas/issues/9

# Note: this requires that a couple of things are configured manually first
# 1. Creation of pveaccess user and group on TrueNAS
# 2. An existing ZFS Pool called "flash-pool" with a dataset called "nfs-shares"
# 3. If SSL is required, need to add the CA certificate to the TrueNAS server
#    NOTE: ACME certificate support is present, but appears broken in 22.12.3.2

resource "truenas_share_nfs" "proxmox_nfs" {
  # disabled for now
  count        = 0
  paths        = ["/mnt/flash-pool/nfs-shares/proxmox-nfs"]
  comment      = "NFS Share for Proxmox VMs"
  networks     = ["10.40.100.0/24", "10.80.100.0/24", "10.66.100.0/24"]
  enabled      = true
  quiet        = false
  ro           = false
  mapall_user  = "pveaccess"
  mapall_group = "pveaccess"
}

resource "truenas_share_nfs" "proxmox_backups" {
  # disabled for now
  count        = 0
  paths        = ["/mnt/flash-pool/nfs-shares/proxmox-backups"]
  comment      = "NFS Share for Proxmox Backups"
  networks     = ["10.80.100.0/24"]
  enabled      = true
  quiet        = false
  ro           = false
  mapall_user  = "pveaccess"
  mapall_group = "pveaccess"
}
