#===============================================================================
# Ansible Playbook to standardize proxmox hosts
#
# WARNING: DO NOT change or move any resources created via terraform, it will break terraform!
#
#===============================================================================


resource "local_file" "ansible_inventory" {
  content  = var.ansible_inventory_content
  filename = "${path.module}/inventory.ini"
}
resource "null_resource" "run_ansible_playbook" {
  depends_on = [ local_file.ansible_inventory ]
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i inventory.ini \
      -u root \
      playbook.yml \
      -e "ntp_server=${var.domain_ntp_server}" \
      -e "fallback_ntp_server=${var.domain_fallback_ntp_server}" \
    EOT
  }
}
