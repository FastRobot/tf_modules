resource "tailscale_acl" "this" {
  acl = var.acl
}

resource "tailscale_tailnet_settings" "this" {
  # Prevents console edits from silently drifting away from the
  # Terraform-managed policy above.
  acls_externally_managed_on = true
  acls_external_link         = var.acls_external_link

  devices_approval_on       = var.devices_approval_on
  devices_auto_updates_on   = var.devices_auto_updates_on
  devices_key_duration_days = var.devices_key_duration_days

  users_approval_on = var.users_approval_on
}
