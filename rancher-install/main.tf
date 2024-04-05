#===============================================================================
# Install Rancher on a K3s cluster
#
#
#===============================================================================

// see helm search repo rancher-stable/rancher --versions
resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  version          = "2.8.3"
  set {
    name  = "hostname"
    value = "rancher.buzzdavidson.com"
  }
  set {
    name  = "replicas"
    value = -1
  }
  set {
    name  = "bootstrapPassword"
    value = var.rancher_bootstrap_password
  }
  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"
  }
  set {
    name  = "letsEncrypt.email"
    value = var.letsencrypt_email
  }
}

# helm chart doesnt seem to like the metallb config here, it leaves the service with a ClusterIP type.
# Update the service as LoadBalancer, then we can get the IP address and update DNS
resource "kubernetes_service" "rancher" {
  metadata {
    name      = "rancher"
    namespace = "cattle-system"
  }
  spec {
    selector = {
      app = "rancher"
    }
    port {
      name        = "https"
      port        = 443
      target_port = 443
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
  depends_on = [helm_release.rancher]
}

resource "dns_a_record_set" "rancher" {
  zone = "buzzdavidson.com."
  name = "rancher"
  addresses = [
    kubernetes_service.rancher.status.0.load_balancer.0.ingress.0.ip
  ]
}

