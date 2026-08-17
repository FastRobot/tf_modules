variable "acl" {
  description = "Tailnet policy document, as a JSON or HuJSON string."
  type        = string
}

variable "acls_external_link" {
  description = "Link shown in the admin console pointing at where the policy is managed."
  type        = string
}

variable "devices_approval_on" {
  description = "Require manual approval before a new device joins."
  type        = bool
  default     = true
}

variable "devices_auto_updates_on" {
  description = "Enable automatic client updates for devices in the tailnet."
  type        = bool
  default     = true
}

variable "devices_key_duration_days" {
  description = "Device key expiry in days."
  type        = number
  default     = 180
}

variable "users_approval_on" {
  description = "Require manual approval before a new user joins. Leave false until every intended user has logged in at least once, otherwise it blocks the logins that establish the tailnet."
  type        = bool
  default     = false
}
