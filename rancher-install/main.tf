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
