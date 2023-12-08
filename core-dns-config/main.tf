
resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu playbook.yml"
  }
}
