#===============================================================================
# Setup Portainer
#
# This module will install docker and portainer on the target VM.  
# The instance will require manual configuration:
#   - navigate to (ip address):9000
#   - set the admin password
#   - set the license key
#   - add the local docker instance as an environment
#   - configure git keys
#   - add repo for desired stacks
#
#===============================================================================


# Prepare the VMs for docker installation
resource "null_resource" "prepare_for_docker" {
  triggers = {
    portainer_hostname = var.portainer_hostname
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.portainer_hostname
      user        = var.vm_account_username
      password    = var.vm_account_password
      agent       = false
      private_key = file("~/.ssh/id_cluster_rsa")
    }
    inline = [
      "sudo ufw disable",
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
    ]
  }
}

resource "null_resource" "install_docker" {
  depends_on = [null_resource.prepare_for_docker]
  triggers = {
    portainer_hostname = var.portainer_hostname
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.portainer_ip_address
      user        = var.vm_account_username
      password    = var.vm_account_password
      agent       = false
      private_key = file("~/.ssh/id_cluster_rsa")
    }
    inline = [
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

resource "null_resource" "install_portainer" {
  depends_on = [null_resource.install_docker]
  triggers = {
    portainer_hostname = var.portainer_hostname
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.portainer_hostname
      user        = var.vm_account_username
      password    = var.vm_account_password
      agent       = false
      private_key = file("~/.ssh/id_cluster_rsa")
    }
    inline = [
      "sudo chown ${var.vm_account_username}:${var.vm_account_username} /home/${var.vm_account_username}/docker-compose.yml",
      "cd /home/${var.vm_account_username}",
      "docker volume create portainer_data",
      "docker network create proxy",
      "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --network proxy portainer/portainer-ee:2.20.1-alpine"
    ]
  }
}

resource "dns_a_record_set" "portainer-service-dns" {
  depends_on = [null_resource.install_portainer]
  zone       = "buzzdavidson.com."
  name       = "*.home"
  addresses = [
    var.portainer_ip_address
  ]
}

