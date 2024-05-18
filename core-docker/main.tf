#===============================================================================
# Setup Docker
#
# This module will install docker on the target VMs.  
#
#===============================================================================

# Prepare the VMs for docker installation
resource "null_resource" "install_docker" {
  for_each = var.docker_hosts
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value
      user        = var.vm_account_username
      password    = var.vm_account_password
      agent       = false
      private_key = file("~/.ssh/id_cluster_rsa")
    }
    inline = [
      "sudo ufw disable",
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
      "sudo apt update",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --batch --no",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update",
      "sudo apt install docker-ce docker-ce-cli containerd.io -y",
      "sudo usermod -aG docker ${var.vm_account_username}",
      "sudo docker run hello-world",
      "sudo touch /var/run/reboot-required",
    ]
  }
}

