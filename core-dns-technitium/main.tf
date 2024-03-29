#===============================================================================
# Configuration for core DNS entries
#
# Prerequisites:
#   1. Technitium DNS server is installed and running on TrueNAS
#   2. Technitium DNS server has blocking configured (not strictly necessary, but a reminder if setting up again)
#   3. Technitium DNS is set up to use cloudflare DNS-OVER-TLS forwarders
#   4. Technitium DNS server has buzzdavidson.com zone configured with:
#      - dynamic updates enabled by IP
#      - access IPs set up
#      - TSIG key configured
#   5. proxmox-1 through -3 MUST be manually set up in technitium PRIOR to running Terraform.
#   6. A record should be created for Technitium DNS server (ns.buzzdavidson.com)
#
# TODO: Keep an eye out for Technitium DNS provider for Terraform to eliminate manual setup
#      
#
#===============================================================================

resource "dns_a_record_set" "truenas-1" {
  zone = "buzzdavidson.com."
  name = "truenas-1"
  addresses = [
    "10.40.100.150"
  ]
}
