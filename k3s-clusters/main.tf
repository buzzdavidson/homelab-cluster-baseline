#===============================================================================
# Ansible Playbook to standardize proxmox hosts
#
# WARNING: DO NOT change or move any resources created via terraform, it will break terraform!
#
#===============================================================================

resource "null_resource" "provision_rancher_cluster" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i k3s-ansible/inventory/rancher/hosts.ini \
      -u root \
      k3s-ansible/site.yml \
      -e apiserver_endpoint="${var.k3s_clusters["rancher"].apiserver_endpoint}" \
      -e metal_lb_ip_range="${var.k3s_clusters["rancher"].metal_lb_ip_range}" \
      -e k3s_token="${var.rancher_join_token}" \
    EOT
  }
}

resource "null_resource" "provision_home_cluster" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i k3s-ansible/inventory/buzzdavidson-home/hosts.ini \
      -u root \
      k3s-ansible/site.yml \
      -e apiserver_endpoint="${var.k3s_clusters["buzzdavidson-home"].apiserver_endpoint}" \
      -e metal_lb_ip_range="${var.k3s_clusters["buzzdavidson-home"].metal_lb_ip_range}" \
      -e k3s_token="${var.rancher_join_token}" \
    EOT
  }
}
