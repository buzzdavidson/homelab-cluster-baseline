variable "buzzdavidson-home-join-token" {
  type        = string
  description = "Join token for the buzzdavidson-home k3s cluster"
  sensitive   = true
}

variable "rancher-join-token" {
  type        = string
  description = "join token for the rancher k3s cluster"
  sensitive   = true
}

variable "k3s_clusters" {
  type = map(object({
    apiserver_endpoint = string
    metal_lb_ip_range  = string
  }))
}
