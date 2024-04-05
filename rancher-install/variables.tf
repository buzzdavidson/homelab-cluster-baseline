variable "rancher_bootstrap_password" {
  type        = string
  sensitive   = true
  description = "Bootstrap password for Rancher"
}
variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}
variable "letsencrypt_email" {
  type        = string
  description = "Email address for Let's Encrypt"
  sensitive   = true
}
