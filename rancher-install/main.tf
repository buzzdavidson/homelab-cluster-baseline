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

# we need to delay here to avoid "error/unauthorized" error
resource "null_resource" "delay" {
  depends_on = [helm_release.rancher]
  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# helm chart doesnt seem to like the metallb config here, it leaves the service with a ClusterIP type.
# Update the service as LoadBalancer, then we can get the IP address and update DNS
resource "kubectl_manifest" "rancher_reconfigure" {
  depends_on = [null_resource.delay]
  yaml_body  = <<EOF
apiVersion: v1
kind: Service
metadata:
  name: rancher
  namespace: cattle-system
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  selector:
    app: rancher
EOF
}

