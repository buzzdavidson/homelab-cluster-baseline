#===============================================================================
# Install cert-manager and Rancher on a K3s cluster
#
#
#===============================================================================
# Delay seems to be required here, cert manager fails with "auth failure" if it runs too soon after the rancher install
resource "null_resource" "wait-for-k3s" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# Don't be surprised if TF apply fails here with an auth error, it seems to be a timing issue
# If it breaks, just run `terraform apply` again, it should proceed
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
    cloudflare-token = var.cloudflare_api_token
  }
  depends_on = [kubernetes_namespace.cert-manager]
}

# NOTE: this does not appear to be working, the CRDs are not being installed.  Manual installation works.
data "http" "cert-manager-crds" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml"
}

resource "kubectl_manifest" "cert-manager-crds" {
  yaml_body  = data.http.cert-manager-crds.response_body
  depends_on = [kubernetes_secret.cloudflare-token-secret, data.http.cert-manager-crds]
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = false
  version          = "v1.14.4"
  values = [
    file("${path.module}/cert-manager-values.yaml")
  ]
  depends_on = [kubectl_manifest.cert-manager-crds]
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body  = file("${path.module}/cluster-issuer.yaml")
  depends_on = [helm_release.cert-manager]
}

resource "kubectl_manifest" "buzzdavidson_certificate" {
  yaml_body  = file("${path.module}/buzzdavidson-certificate.yaml")
  depends_on = [kubectl_manifest.cluster-issuer]
}


