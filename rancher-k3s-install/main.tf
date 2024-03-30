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
      ansible-playbook \
      -i inventory/my_cluster/hosts.ini \
      -u root \
      site.yml
    EOT
  }
}
