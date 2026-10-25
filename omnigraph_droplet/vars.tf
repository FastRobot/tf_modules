# --- droplet ---------------------------------------------------------------

variable "name" {
  description = "Name for the droplet, volume, tunnel and Access applications."
  type        = string
  default     = "omnigraph"
}

variable "region" {
  description = "DigitalOcean region slug."
  type        = string
  default     = "sfo3"
}

variable "size" {
  description = "Droplet size slug. 1 GB is the practical floor for OmniGraph; cloud-init adds 2 GB of swap."
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_image" {
  description = "Droplet base image slug."
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "volume_size_gb" {
  description = "Size of the block-storage volume that holds the OmniGraph cluster root. Data lives here, not on the droplet's disk."
  type        = number
  default     = 10
}

variable "ssh_public_keys" {
  description = "SSH public keys to register in DigitalOcean and install for root. DigitalOcean refuses a key the account already holds; pass that one through ssh_key_fingerprints instead."
  type        = list(string)
  default     = []
}

variable "ssh_key_fingerprints" {
  description = "MD5 fingerprints (or IDs) of SSH keys already registered in the DigitalOcean account, installed for root."
  type        = list(string)
  default     = []
}

variable "ssh_source_addresses" {
  description = "CIDRs allowed to reach port 22. Empty means no inbound SSH (use Tailscale or the DO console)."
  type        = list(string)
  default     = []
}

variable "tailscale_auth_key" {
  description = "Optional Tailscale auth key; when set the droplet joins the tailnet with tailscale_tags."
  type        = string
  default     = null
  sensitive   = true
}

variable "tailscale_tags" {
  description = "Tags the droplet advertises when joining the tailnet."
  type        = list(string)
  default     = ["tag:server"]
}

# --- containers ------------------------------------------------------------

variable "omnigraph_image" {
  description = "OmniGraph server image, pinned to a release tag. Docker Hub is the public pull channel; the GHCR copy needs registry_auth."
  type        = string
  default     = "docker.io/modernrelay/omnigraph-server:v0.14.0"
}

variable "registry_auth" {
  description = "Optional credentials for pulling omnigraph_image (for example a GitHub PAT with read:packages for ghcr.io)."
  type = object({
    server   = string
    username = string
    password = string
  })
  default   = null
  sensitive = true
}

variable "cloudflared_image" {
  type    = string
  default = "cloudflare/cloudflared:2026.10.3"
}

variable "caddy_image" {
  type    = string
  default = "caddy:2.11.7-alpine"
}

# --- cloudflare ------------------------------------------------------------

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  description = "Zone that hostname and api_hostname live in."
  type        = string
}

variable "cloudflare_team_name" {
  description = "Zero Trust team name (the <team> in <team>.cloudflareaccess.com); cloudflared validates Access tokens against it."
  type        = string
}

variable "google_identity_provider_id" {
  description = "Access identity provider browser users log in with."
  type        = string
}

variable "hostname" {
  description = "Browser hostname, behind Google login, for example omnigraph.example.com."
  type        = string
}

variable "api_hostname" {
  description = "Hostname for non-browser clients (CLI, MCP, scripts) authenticating with an Access service token plus their own OmniGraph bearer token. Null disables it."
  type        = string
  default     = null
}

variable "session_duration" {
  type    = string
  default = "24h"
}

# --- identities ------------------------------------------------------------

variable "users" {
  description = "Google account email => OmniGraph actor ID (for example \"act-lamont\"). Each email is admitted by Access and mapped by Caddy to that actor's bearer token. Grant the actors permissions in the cluster's Cedar policy."
  type        = map(string)
}

variable "service_clients" {
  description = "Client name => OmniGraph actor ID for api_hostname clients. Each gets an Access service token and an OmniGraph bearer token."
  type        = map(string)
  default     = {}
}

# --- MCP and OAuth ----------------------------------------------------------

variable "oauth_redirect_uris" {
  description = "HTTPS redirect URIs (may end in /*) that dynamically registered OAuth clients may use, besides localhost/127.0.0.1. The default admits Claude.ai custom connectors."
  type        = list(string)
  default     = ["https://claude.ai/api/mcp/auth_callback"]
}

variable "oauth_access_token_lifetime" {
  description = "Lifetime of Access-issued OAuth access tokens; clients refresh silently."
  type        = string
  default     = "15m"
}

variable "oauth_session_duration" {
  description = "Lifetime of the OAuth grant (refresh token) before Google sign-in is needed again."
  type        = string
  default     = "336h"
}

variable "mcp_allow_writes" {
  description = "Enable the server's MCP write tools (mutate, load, branches). Cedar policy still decides each call."
  type        = bool
  default     = false
}

variable "mcp_allow_adhoc" {
  description = "Enable the MCP ad-hoc GQ read tool."
  type        = bool
  default     = false
}
