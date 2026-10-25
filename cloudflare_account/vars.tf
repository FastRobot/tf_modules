variable "account_id" {
  description = "Cloudflare account ID that owns the zones and the Zero Trust organization."
  type        = string
}

variable "zones" {
  description = "Zones to manage fully on Cloudflare (type = full). After the first apply, point the registrar's nameservers at the zone's name_servers output."
  type        = set(string)
  default     = []
}

variable "google_oauth_client_id" {
  description = "OAuth 2.0 client ID of a Google Cloud 'Web application' client whose authorized redirect URI is https://<team>.cloudflareaccess.com/cdn-cgi/access/callback. Null skips the Google identity provider."
  type        = string
  default     = null
}

variable "google_oauth_client_secret" {
  description = "Secret of the Google OAuth client above."
  type        = string
  default     = null
  sensitive   = true
}
