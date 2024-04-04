#===============================================================================
# Install Rancher on a K3s cluster
#
#
#===============================================================================

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.14.4"
  set {
    name  = "installCRDs"
    value = true
  }
  set {
    name  = "global.rbac.create"
    value = true
  }
  set {
    name  = "webhook.enabled"
    value = true
  }
  set {
    name  = "cainjector.enabled"
    value = true
  }
  set {
    name  = "webhook.service.type"
    value = "ClusterIP"
  }
}
// see https://registry.terraform.io/modules/terraform-iaac/cert-manager/kubernetes/latest
// see helm search repo rancher-stable/rancher --versions
resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  version          = "2.8.3"
  depends_on       = [helm_release.cert-manager]
  set {
    name  = "hostname"
    value = "rancher.buzzdavidson.com"
  }
  set {
    name  = "replicas"
    value = 1
  }
  set {
    name  = "bootstrapPassword"
    value = var.rancher_bootstrap_password
  }
}
