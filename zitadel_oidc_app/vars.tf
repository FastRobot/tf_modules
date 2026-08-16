variable "org_id" {
  description = "ZITADEL organization ID. When null, the organization of the authenticated service user is used."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the ZITADEL project holding the OIDC application."
  type        = string
}

variable "app_name" {
  description = "Name of the OIDC application."
  type        = string
}

variable "redirect_uris" {
  description = "Allowed OIDC redirect URIs. For Tailscale this is exactly [\"https://login.tailscale.com/a/oauth_response\"]."
  type        = list(string)
}

variable "users" {
  description = "Human users to create and grant access to the project, keyed by a short identifier."
  type = map(object({
    email      = string
    first_name = string
    last_name  = string
  }))
  default = {}
}

variable "initial_passwords" {
  description = "Optional bootstrap password override per user key, matching the keys of var.users. When a key is absent, a random password is generated instead, since is_email_verified can only be true when a password is set."
  type        = map(string)
  sensitive   = true
  default     = {}
}
