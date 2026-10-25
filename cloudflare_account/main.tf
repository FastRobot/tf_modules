# Account-wide Cloudflare resources that individual services build on: the
# zones whose DNS Cloudflare serves, and the Zero Trust identity providers
# their Access applications log users in with.
#
# The Zero Trust organization itself (team name, plan) is created once by
# onboarding in the dashboard and is not managed here.

resource "cloudflare_zone" "this" {
  for_each = var.zones

  account = { id = var.account_id }
  name    = each.value
  type    = "full"
}

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  count = var.google_oauth_client_id == null ? 0 : 1

  account_id = var.account_id
  name       = "Google"
  type       = "google"
  config = {
    client_id     = var.google_oauth_client_id
    client_secret = var.google_oauth_client_secret
  }
}
