#===============================================================================
# Install Emberstack reflector to mirror K8s resources
#
#
#===============================================================================

// see helm search repo rancher-stable/rancher --versions
resource "helm_release" "rancher-emberstack-reflector" {
  name             = "rancher-emberstack-reflector"
  repository       = "https://emberstack.github.io/helm-charts"
  chart            = "reflector"
  namespace        = "kube-system"
  create_namespace = false
  version          = "v7.1.262"
}


