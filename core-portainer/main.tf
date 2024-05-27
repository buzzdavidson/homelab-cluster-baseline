#===============================================================================
# Setup Portainer
#
# This module will install and configure portainer on the target VM.  
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

resource "null_resource" "wait_for_portainer" {
  depends_on = [null_resource.install_portainer_agent]
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "terracurl_request" "portainer_init_admin_user" {
  name            = "portainer_init_admin_user"
  depends_on      = [null_resource.wait_for_portainer]
  url             = "https://${var.portainer_hostname}:9443/api/users/admin/init"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Content-Type = "application/json"
  }
  request_body = jsonencode(
    {
      "Username" = "admin",
      "Password" = var.portainer_admin_password
  })
  response_codes = [200, 409]
}

locals {
  initial_run = contains(data.terracurl_request.portainer_init_admin_user.response, 200)
}

data "http" "portainer_login_admin_user" {
  depends_on = [terracurl_request.portainer_init_admin_user]
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
  homelab_monorepo_url   = "https://github.com/buzzdavidson/homelab-cluster-gitops-monorepo.git"
  homelab_monorepo_ref   = "refs/heads/main"
}

# Note: Already idempotent
resource "terracurl_request" "portainer_user_settings" {
  name            = "portainer_user_settings"
  depends_on      = [data.http.portainer_login_admin_user]
  url             = "https://${var.portainer_hostname}:9443/api/users/${local.portainer_admin_userid}"
  skip_tls_verify = true
  method          = "PUT"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "theme" : {
      "color" : "dark",
      "subtleUpgradeButton" : true
    }
  })
  response_codes = [200]
}

# Note: Already idempotent
resource "terracurl_request" "portainer_license" {
  name            = "portainer_license"
  count           = local.initial_run ? 1 : 0
  depends_on      = [terracurl_request.portainer_user_settings]
  url             = "https://${var.portainer_hostname}:9443/api/licenses/add"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "key" : var.portainer_license_key
    "force" : true
  })
  response_codes = [200]
}

# Note: Only run on first execution
resource "terracurl_request" "portainer_settings_blacklist" {
  name            = "portainer_settings_blacklist"
  count           = local.initial_run ? 1 : 0
  depends_on      = [terracurl_request.portainer_license]
  url             = "https://${var.portainer_hostname}:9443/api/settings"
  skip_tls_verify = true
  method          = "PUT"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "blackListedLabels" : [{ "name" : "com.buzzdavidson.portainer", "value" : "hide" }]
  })
  response_codes = [200]
}

# Note: Already idempotent
resource "terracurl_request" "portainer_settings_experimental" {
  name            = "portainer_settings_experimental"
  depends_on      = [terracurl_request.portainer_settings_blacklist]
  url             = "https://${var.portainer_hostname}:9443/api/settings/experimental"
  skip_tls_verify = true
  method          = "PUT"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "openAIIntegration" : true
  })
  response_codes = [204]
}

# Note: Already idempotent
data "terracurl_request" "portainer_openai_key" {
  name            = "portainer_openai_key"
  depends_on      = [terracurl_request.portainer_settings_experimental]
  url             = "https://${var.portainer_hostname}:9443/api/users/${local.portainer_admin_userid}/openai"
  skip_tls_verify = true
  method          = "PUT"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "apiKey" = var.portainer_openai_key
  })
  response_codes = [204]
}

# TODO: check if credentials already exist; if so, set the count of this resource to 0, otherwise 1
# TODO: we need another ssolution here, we need the credential id for later
resource "terracurl_request" "portainer_git_credentials" {
  name  = "portainer_git_credentials"
  depends_on      = [data.terracurl_request.portainer_openai_key]
  url             = "https://${var.portainer_hostname}:9443/api/users/${local.portainer_admin_userid}/gitcredentials"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_body = jsonencode({
    "name"     = "buzzdavidson-github-token",
    "username" = "buzzdavidson",
    "password" = var.github_access_token
  })
  response_codes = [201]

}

locals {
  portainer_git_credentials_id = jsondecode(resource.terracurl_request.portainer_git_credentials.response)["gitCredential"]["id"]
}

# TODO: check if environment already exist; if so, set the count of this resource to 0, otherwise 1
# Note: this could be made a submodule to make it more DRY
resource "terracurl_request" "portainer_env_core" {
  name            = "portainer_env_core"
  depends_on      = [terracurl_request.portainer_git_credentials]
  url             = "https://${var.portainer_hostname}:9443/api/endpoints"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_parameters = {
    "Name"                 = "core-docker",
    "EndpointCreationType" = 2,
    "URL"                  = "https://core-docker-1.buzzdavidson.com:9001",
    "TLS"                  = true,
    "TLSSkipVerify"        = true,
    "TLSSkipClientVerify"  = true,
  }
  response_codes = [200]
}

locals {
  portainer_env_core_id = jsondecode(resource.terracurl_request.portainer_env_core.response)["Id"]
}

# TODO: check if environment already exist; if so, set the count of this resource to 0, otherwise 1
resource "terracurl_request" "portainer_env_home" {
  name            = "portainer_env_home"
  depends_on      = [terracurl_request.portainer_env_core]
  url             = "https://${var.portainer_hostname}:9443/api/endpoints"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_parameters = {
    "Name"                 = "home-docker",
    "EndpointCreationType" = 2,
    "URL"                  = "https://home-docker-1.buzzdavidson.com:9001",
    "TLS"                  = true,
    "TLSSkipVerify"        = true,
    "TLSSkipClientVerify"  = true,
  }
  response_codes = [200]
}

locals {
  portainer_env_home_id = jsondecode(resource.terracurl_request.portainer_env_home.response)["Id"]
}
# TODO: check if environment already exist; if so, set the count of this resource to 0, otherwise 1
resource "terracurl_request" "portainer_env_gizmo" {
  name            = "portainer_env_gizmo"
  depends_on      = [terracurl_request.portainer_env_home]
  url             = "https://${var.portainer_hostname}:9443/api/endpoints"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_parameters = {
    "Name"                 = "gizmo-docker",
    "EndpointCreationType" = 2,
    "URL"                  = "https://gizmo-docker-1.buzzdavidson.com:9001",
    "TLS"                  = true,
    "TLSSkipVerify"        = true,
    "TLSSkipClientVerify"  = true,
  }
  response_codes = [200]
}

locals {
  portainer_env_gizmo_id = jsondecode(resource.terracurl_request.portainer_env_gizmo.response)["Id"]
}

# TODO: check if stack already exist; if so, set the count of this resource to 0, otherwise 1
resource "terracurl_request" "portainer_stack_core_admin" {
  name            = "portainer_stack_core_admin"
  depends_on      = [terracurl_request.portainer_env_core]
  url             = "https://${var.portainer_hostname}:9443/api/stacks/create/standalone/repository"
  skip_tls_verify = true
  method          = "POST"
  headers = {
    Authorization = "Bearer ${local.portainer_jwt_token}"
    Content-Type  = "application/json"
  }
  request_parameters = {
    "endpointId" = "${local.portainer_env_core_id}",
  }
  request_body = jsonencode({
    "name" = "core-admin",
    "autoUpdate" = {
      "forcePullImage" = false,
      "forceUpdate"    = false,
      "interval"       = "5m"
    },
    "composeFile"               = "docker/core/admin/docker-compose.yml",
    "repositoryAuthentication"  = true,
    "repositoryGitCredentialId" = "${local.portainer_git_credentials_id}",
    "repositoryReferenceName"   = "${local.homelab_monorepo_ref}",
    "repositoryUrl"             = "${local.homelab_monorepo_url}",
    "env" = [
      {
        "name"  = "CF_DNS_API_TOKEN",
        "value" = "${var.cloudflare_access_key}"
      },
    ]
  })
  response_codes = [200]
  timeout        = 120
}
