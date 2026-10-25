# Cloudflare Tunnel (outbound-only from the droplet) and Access in front of it.
#
#   hostname      Google login (users)            -> caddy:8081, which maps the email to a bearer token
#   api_hostname  Access service token (clients)  -> caddy:8082, which passes the client's own bearer token
#
# cloudflared also validates each request's Access JWT against the
# application's audience, so traffic that did not pass Access never reaches Caddy.

resource "random_bytes" "tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id    = var.cloudflare_account_id
  name          = var.name
  config_src    = "cloudflare"
  tunnel_secret = random_bytes.tunnel_secret.base64
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

resource "cloudflare_dns_record" "browser" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "api" {
  count = var.api_hostname == null ? 0 : 1

  zone_id = var.cloudflare_zone_id
  name    = var.api_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

# --- browser users: Google login, explicit email list ----------------------

resource "cloudflare_zero_trust_access_policy" "users" {
  account_id = var.cloudflare_account_id
  name       = "${var.name} users"
  decision   = "allow"
  include    = [for email in keys(local.users) : { email = { email = email } }]
}

resource "cloudflare_zero_trust_access_application" "browser" {
  account_id                = var.cloudflare_account_id
  name                      = var.name
  domain                    = var.hostname
  type                      = "self_hosted"
  session_duration          = var.session_duration
  allowed_idps              = [var.google_identity_provider_id]
  auto_redirect_to_identity = true
  policies = [{
    id         = cloudflare_zero_trust_access_policy.users.id
    precedence = 1
  }]
}

# --- service clients: Access service tokens ---------------------------------

resource "cloudflare_zero_trust_access_service_token" "client" {
  for_each = var.api_hostname == null ? {} : var.service_clients

  account_id = var.cloudflare_account_id
  name       = "${var.name} ${each.key}"
  duration   = "8760h"
}

resource "cloudflare_zero_trust_access_policy" "clients" {
  count = var.api_hostname == null || length(var.service_clients) == 0 ? 0 : 1

  account_id = var.cloudflare_account_id
  name       = "${var.name} service clients"
  decision   = "non_identity"
  include = [for token in cloudflare_zero_trust_access_service_token.client :
    { service_token = { token_id = token.id } }
  ]
}

resource "cloudflare_zero_trust_access_application" "api" {
  count = var.api_hostname == null ? 0 : 1

  account_id       = var.cloudflare_account_id
  name             = "${var.name} api"
  domain           = var.api_hostname
  type             = "self_hosted"
  session_duration = var.session_duration
  # No identity provider: only service tokens are admitted.
  allowed_idps = []
  policies = [for policy in cloudflare_zero_trust_access_policy.clients : {
    id         = policy.id
    precedence = 1
  }]
}

# --- tunnel routing ----------------------------------------------------------

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config = {
    ingress = concat(
      [{
        hostname = var.hostname
        service  = "http://caddy:8081"
        origin_request = {
          access = {
            required  = true
            team_name = var.cloudflare_team_name
            aud_tag   = [cloudflare_zero_trust_access_application.browser.aud]
          }
        }
      }],
      [for app in cloudflare_zero_trust_access_application.api : {
        hostname = var.api_hostname
        service  = "http://caddy:8082"
        origin_request = {
          access = {
            required  = true
            team_name = var.cloudflare_team_name
            aud_tag   = [app.aud]
          }
        }
      }],
      [{ service = "http_status:404" }],
    )
  }
}
