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

locals {
  # Single source of truth for each user's bootstrap password: an explicit
  # override from var.initial_passwords when present, otherwise the random
  # password generated below. Both zitadel_human_user and the
  # initial_passwords output read from this local so they can never diverge.
  effective_passwords = {
    for k, _ in var.users : k => try(var.initial_passwords[k], random_password.initial[k].result)
  }
}

resource "random_password" "initial" {
  # Skip generating (and storing in state) a password for any user whose
  # password comes from var.initial_passwords instead — it would otherwise
  # sit in state unused. try() in local.effective_passwords short-circuits
  # before referencing random_password.initial[k] for those keys.
  #
  # nonsensitive() here only strips sensitivity from the *keys* of
  # var.initial_passwords (short user identifiers, e.g. "lamont") for use in
  # for_each, which Terraform otherwise refuses on a sensitive-derived value
  # even though only the map's values, not its keys, are actually secret.
  for_each = { for k, v in var.users : k => v if !contains(nonsensitive(keys(var.initial_passwords)), k) }

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
  # requires a verified email claim. See local.effective_passwords for the
  # override-vs-generated logic.
  initial_password  = local.effective_passwords[each.key]
  is_email_verified = true

  # Without this the user hits a forced password-change screen on first login,
  # which would land inside Tailscale's one-shot signup redirect and break it.
  initial_skip_password_change = true

  lifecycle {
    precondition {
      # The provider docs claim org_id falls back to the service account's
      # organization when omitted — that's true for the v1-API resources
      # (zitadel_project, zitadel_application_oidc) but NOT for
      # zitadel_human_user, which uses the user/v2 API. Omitting org_id here
      # sends an empty string and ZITADEL rejects it with a gRPC
      # InvalidArgument at apply time. Fail immediately instead.
      condition     = var.org_id != null && var.org_id != ""
      error_message = "org_id must be set when var.users is non-empty: the ZITADEL user/v2 API requires an explicit organization ID and does not fall back to the service account's organization."
    }
  }
}

resource "zitadel_user_grant" "this" {
  for_each = var.users

  org_id     = var.org_id
  project_id = zitadel_project.this.id
  user_id    = zitadel_human_user.this[each.key].id
}
