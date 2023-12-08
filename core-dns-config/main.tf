
resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i inventory.ini \
      -u ${var.vm_account_username} \
      playbook.yml 
    EOT
  }
}
