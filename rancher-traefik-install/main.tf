#===============================================================================
# Install Traefik for rancher cluster
#
#
#===============================================================================

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "v27.0.0"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  depends_on = [kubernetes_namespace.traefik]
  values = [
    file("${path.module}/traefik-values.yaml")
  ]
}

# can't seem to be able to apply this one with the kubectl provider
resource "null_resource" "apply_default_headers" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/default_headers.yaml"
  }

  depends_on = [helm_release.traefik]
}

resource "dns_a_record_set" "buzzdavidson" {
  zone = "buzzdavidson.com."
  name = "*"
  addresses = [
    "10.100.100.125"
  ]
  depends_on = [null_resource.apply_default_headers]
}

# can't seem to be able to apply this one with the kubectl provider
resource "null_resource" "apply_dashboard_auth" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/traefik-dashboard-auth.yaml"
  }

  depends_on = [dns_a_record_set.buzzdavidson]
}

# can't seem to be able to apply this one with the kubectl provider
resource "null_resource" "apply_dashboard_middleware" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/traefik-dashboard-middleware.yaml"
  }

  depends_on = [null_resource.apply_dashboard_auth]
}

# can't seem to be able to apply this one with the kubectl provider
resource "null_resource" "apply_dashboard_ingress" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/traefik-dashboard-ingress.yaml"
  }

  depends_on = [null_resource.apply_dashboard_middleware]
}

