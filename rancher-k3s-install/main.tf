#===============================================================================
# Ansible Playbook to install k3s
#
# WARNING: DO NOT change or move any resources created via terraform, it will break terraform!
#
#===============================================================================

resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i inventory.ini \
      -u root \
      playbook.yml \
      -e "rancher_k3s_join_token=${var.rancher_k3s_join_token}" \
    EOT
  }
}
