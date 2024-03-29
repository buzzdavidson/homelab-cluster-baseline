# Fixed DNS entries go here
#
# SMD: Keep an eye out for Technitium DNS provider for Terraform, we could manage all setup here.
# SMD: proxmox-1 through -3 MUST be manually set up in technitium PRIOR to running Terraform.

# resource "dns_a_record_set" "proxmox-1" {
#   zone = "buzzdavidson.com."
#   name = "proxmox-1"
#   addresses = [
#     "10.80.100.21"
#   ]
# }

resource "dns_a_record_set" "truenas-1" {
  zone = "buzzdavidson.com."
  name = "truenas-1"
  addresses = [
    "10.40.100.150"
  ]
}
