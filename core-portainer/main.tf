#===============================================================================
# Setup Portainer
#
# This module will install portainer on the target VM.  
# The instance will require manual configuration:
#   - navigate to (ip address):9000
#   - set the admin password
#   - set the license key
#   - add the local docker instance as an environment
#   - configure git keys
#   - add repo for desired stacks
#
#===============================================================================

resource "null_resource" "install_portainer" {
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
      # "sudo chown ${var.vm_account_username}:${var.vm_account_username} /home/${var.vm_account_username}/docker-compose.yml",
      # "cd /home/${var.vm_account_username}",
      "docker run -d -p 8000:8000 -p 9443:9443 --label com.buzzdavidson.portainer=hide --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/applications/core/portainer:/data portainer/portainer-ee:${var.portainer_version}-alpine"
    ]
  }
}

resource "dns_a_record_set" "home-service-dns" {
  depends_on = [null_resource.install_portainer]
  zone       = "buzzdavidson.com."
  name       = "*.home"
  addresses = [
    "10.160.100.70"
  ]
}

resource "dns_a_record_set" "core-service-dns" {
  depends_on = [null_resource.install_portainer]
  zone       = "buzzdavidson.com."
  name       = "*.core"
  addresses = [
    "10.160.100.72"
  ]
}

resource "dns_a_record_set" "gizmo-service-dns" {
  depends_on = [null_resource.install_portainer]
  zone       = "buzzdavidson.com."
  name       = "*.gizmo"
  addresses = [
    "10.160.100.74"
  ]
}

resource "dns_a_record_set" "primary-service-dns" {
  depends_on = [null_resource.install_portainer]
  zone       = "buzzdavidson.com."
  name       = "*"
  addresses = [
    "10.160.100.100"
  ]
}

resource "null_resource" "install_portainer_agent" {
  depends_on = [dns_a_record_set.primary-service-dns]
  for_each   = var.docker_hosts
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
      "docker run -d -p 9001:9001 --label com.buzzdavidson.portainer=hide --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:${var.portainer_version}"
    ]
  }
}

resource "http" "portainer_admin_password" {
  depends_on = [null_resource.install_portainer]
  url        = "https://${var.portainer_hostname}:9443/api/users/admin/init"
  method     = "POST"
  headers = {
    "Content-Type" = "application/json"
  }
  body = jsonencode({
    "Username" = "admin",
    "Password" = var.portainer_admin_password
  })
}

output "portainer_jwt_token" {
  value = jsondecode(http.portainer_admin_password.body)["jwt"]
}

# future: post /restore to restore a backup
# future: post /chat to use openAI

# put /settings, "blackListedLabels": [{"name": "com.buzzdavidson.portainer", "value": "hide"}]
# post /settings/experimental to enable openAI
# post /users/{id}/openai to set openAI key
# post /users/{id}/gitcredentials to add git credentials
# post /stacks/create/standalone/repository to set up stack
# post /upload/tls/certificate


resource "http" "portainer_license" {
  depends_on = [http.portainer_admin_password, output.portainer_jwt_token]
  url        = "https://${var.portainer_hostname}:9443/api/licenses/add"
  method     = "POST"
  headers = {
    "Authorization" = "Bearer ${output.portainer_jwt_token}"
    "Content-Type"  = "application/json"
  }
  body = jsonencode({
    "license" = var.portainer_license_key
  })
}

