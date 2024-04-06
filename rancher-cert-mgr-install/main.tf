#===============================================================================
# Install cert-manager and Rancher on a K3s cluster
#
#
#===============================================================================
# Delay seems to be required here, cert manager fails with "auth failure" if it runs too soon after the rancher install
resource "null_resource" "wait-for-k3s" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [null_resource.wait-for-k3s]
}

resource "kubernetes_secret" "cloudflare-token-secret" {
  metadata {
    name      = "cloudflare-token-secret"
    namespace = "cert-manager"
  }
  type = "Opaque"
  data = {
    cloudflare_token = var.cloudflare_api_token
  }
  depends_on = [kubernetes_namespace.cert-manager]
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.14.4"
  values = [
    file("${path.module}/cert-manager-values.yaml")
  ]
  depends_on = [kubernetes_secret.cloudflare-token-secret]
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body  = file("${path.module}/cluster-issuer.yaml")
  depends_on = [helm_release.cert-manager]
}

resource "kubectl_manifest" "buzzdavidson_certificate" {
  yaml_body  = file("${path.module}/buzzdavidson-certificate.yaml")
  depends_on = [kubectl_manifest.cluster-issuer]
}


