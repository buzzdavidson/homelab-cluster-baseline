#===============================================================================
# Install Rancher on a K3s cluster
#
#
#===============================================================================
data "http" "cert-manager-crd-yaml" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml"
}

resource "kubectl_manifest" "cert-manager-crd-manifest" {
  yaml_body  = data.http.cert-manager-crd-yaml.body
  depends_on = [data.http.cert-manager-crd-yaml]
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.14.4"
  depends_on       = [kubectl_manifest.cert-manager-crd-manifest]
}
// see https://registry.terraform.io/modules/terraform-iaac/cert-manager/kubernetes/latest
resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://rancher.github.io/charts"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  version          = "2.5.7"
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
