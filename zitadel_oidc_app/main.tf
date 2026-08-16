resource "zitadel_project" "this" {
  name   = var.project_name
  org_id = var.org_id
}

resource "zitadel_application_oidc" "this" {
  org_id     = var.org_id
  project_id = zitadel_project.this.id

  name           = var.app_name
  redirect_uris  = var.redirect_uris
  response_types = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types    = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]

  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"
  version          = "OIDC_VERSION_1_0"

  # dev_mode relaxes redirect URI validation. A production relying party must
  # never have it enabled.
  dev_mode = false
}

resource "random_password" "initial" {
  for_each = var.users

  length           = 32
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

resource "zitadel_human_user" "this" {
  for_each = var.users

  org_id     = var.org_id
  user_name  = each.value.email
  email      = each.value.email
  first_name = each.value.first_name
  last_name  = each.value.last_name

  # is_email_verified can only be true when a password is set, and Tailscale
  # requires a verified email claim. var.initial_passwords is an optional
  # override; absent an entry, a random password is generated instead.
  initial_password  = try(var.initial_passwords[each.key], random_password.initial[each.key].result)
  is_email_verified = true

  # Without this the user hits a forced password-change screen on first login,
  # which would land inside Tailscale's one-shot signup redirect and break it.
  initial_skip_password_change = true
}

resource "zitadel_user_grant" "this" {
  for_each = var.users

  org_id     = var.org_id
  project_id = zitadel_project.this.id
  user_id    = zitadel_human_user.this[each.key].id
}
