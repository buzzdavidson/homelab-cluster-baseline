
resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    working_dir = path.module
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i inventory.ini \
      -u root \
      playbook.yml \
      -e ntp-server=${var.domain_ntp_server} \
      -e fallback-ntp-server=${var.domain_fallback_ntp_server} \
    EOT
  }
}
