variable "buzzdavidson_home_join_token" {
  type        = string
  description = "Join token for the buzzdavidson-home k3s cluster"
}

variable "rancher_join_token" {
  type        = string
  description = "join token for the rancher k3s cluster"
}

variable "k3s_clusters" {
  type = map(object({
    apiserver_endpoint = string
    metal_lb_ip_range  = string
  }))
}
