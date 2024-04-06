variable "letsencrypt_email" {
  type        = string
  description = "Email address for Let's Encrypt"
  sensitive   = true
}

variable "cloudflare_api_token" {
  type        = string
  description = "API Token for Cloudflare"
  sensitive   = true
}
