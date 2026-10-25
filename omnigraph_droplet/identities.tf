# One OmniGraph bearer token per actor. Browser users never see theirs:
# Caddy swaps the Access-authenticated email for it. Service clients send
# theirs themselves on api_hostname.

locals {
  users = { for email, actor in var.users : lower(email) => actor }

  actors = merge(
    { for email, actor in local.users : actor => actor },
    { for _, actor in var.service_clients : actor => actor },
  )
}

resource "random_password" "actor_token" {
  for_each = local.actors

  length  = 48
  special = false
}

locals {
  # The server's OMNIGRAPH_SERVER_BEARER_TOKENS_FILE format: actor => token.
  tokens_json = jsonencode({ for actor, _ in local.actors : actor => random_password.actor_token[actor].result })

  caddyfile = templatefile("${path.module}/templates/Caddyfile.tftpl", {
    user_tokens = { for email, actor in local.users : email => random_password.actor_token[actor].result }
  })
}
