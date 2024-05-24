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
# https://www.hashicorp.com/blog/writing-terraform-for-unsupported-resources
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

data "http" "portainer_init_admin_user" {
  depends_on = [null_resource.install_portainer]
  url        = "https://${var.portainer_hostname}:9443/api/users/admin/init"
  insecure   = true
  method     = "POST"
  request_headers = {
    Content-Type = "application/json"
  }
  request_body = jsonencode({
    "Username" = "admin",
    "Password" = var.portainer_admin_password
  })
}

resource "null_resource" "check_portainer_init_admin_user" {
  # This will return a 409 if the user already exists, that's fine
  #
  # On success, this will attempt to execute the true command in the
  # shell environment running terraform.
  # On failure, this will attempt to execute the false command in the
  # shell environment running terraform.
  depends_on = [data.http.portainer_init_admin_user]
  provisioner "local-exec" {
    command = contains([200, 409], data.http.portainer_init_admin_user.status_code)
  }
}

data "http" "portainer_login_admin_user" {
  depends_on = [null_resource.check_portainer_init_admin_user]
  url        = "https://${var.portainer_hostname}:9443/api/auth"
  insecure   = true
  method     = "POST"
  request_headers = {
    Content-Type = "application/json"
  }
  request_body = jsonencode({
    "username" = "admin",
    "password" = var.portainer_admin_password
  })
}

locals {
  portainer_jwt_token    = jsondecode(data.http.portainer_login_admin_user.response_body)["jwt"]
  portainer_admin_userid = 1
}

data "http" "portainer_user_settings" {
  depends_on = [data.http.portainer_login_admin_user]
  url        = "https://${var.portainer_hostname}:9443/api/users/${local.portainer_admin_userid}"
  insecure   = true
  #method     = "PUT"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "theme" : {
      "color" : "dark",
      "subtleUpgradeButton" : true
    }
  })
}

# # future: post /restore to restore a backup
# # future: post /chat to use openAI
# # future: post /upload/tls/certificate
# # post /stacks/create/standalone/repository to set up stack

data "http" "portainer_license" {
  depends_on = [data.http.portainer_user_settings]
  url        = "https://${var.portainer_hostname}:9443/api/licenses/add"
  insecure   = true
  method     = "POST"
  request_headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "key" = var.portainer_license_key
  })
}

data "http" "portainer_settings_blacklist" {
  depends_on = [data.http.portainer_license]
  url        = "https://${var.portainer_hostname}:9443/api/settings"
  insecure   = true
  #method     = "PUT"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "blackListedLabels" = [{ "name" : "com.buzzdavidson.portainer", "value" : "hide" }]
  })
}

data "http" "portainer_settings_experimental" {
  depends_on = [data.http.portainer_settings_blacklist]
  url        = "https://${var.portainer_hostname}:9443/api/settings/experimental"
  insecure   = true
  #method     = "PUT"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "openAIIntegration" = true
  })
}

data "http" "portainer_openai_key" {
  depends_on = [data.http.portainer_settings_experimental]
  url        = "https://${var.portainer_hostname}:9443/api/users/${local.portainer_admin_userid}/openai"
  insecure   = true
  #method     = "PUT"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "apiKey" = var.portainer_openai_key
  })
}

data "http" "portainer_git_credentials" {
  depends_on = [data.http.portainer_openai_key]
  url        = "https://${var.portainer_hostname}:9443/api/users/${local.portainer_admin_userid}/gitcredentials"
  insecure   = true
  method     = "POST"
  request_headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "name"     = "buzzdavidson-github-token",
    "username" = "buzzdavidson",
    "password" = var.github_access_token
  })
}
