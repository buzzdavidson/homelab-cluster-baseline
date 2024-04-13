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
      "docker run hello-world",
    ]
  }
}

resource "docker_network" "proxy" {
  depends_on = [null_resource.install_docker]
  provider   = docker
  name       = "proxy"
}

resource "docker_volume" "portainer_data" {
  depends_on = [null_resource.install_docker]
  provider   = docker
  name       = "portainer_data"
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_container" "portainer" {
  depends_on = [docker_network.proxy]
  provider   = docker
  name       = "portainer"
  image      = "portainer/portainer-ee:latest"
  restart    = "unless-stopped"
  ports {
    internal = 9000
    external = 9000
  }
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    container_path = "/data"
    volume_name    = docker_volume.portainer_data.name
  }
  networks_advanced {
    name = docker_network.proxy.name
  }
}

resource "dns_a_record_set" "portainer-service-dns" {
  depends_on = [docker_container.portainer]
  zone       = "buzzdavidson.com."
  name       = "*.home"
  addresses = [
    var.portainer_ip_address
  ]
}

