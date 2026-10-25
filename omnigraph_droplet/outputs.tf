output "droplet_ipv4" {
  value = digitalocean_droplet.this.ipv4_address
}

output "volume_id" {
  value = digitalocean_volume.data.id
}

output "tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

output "url" {
  value = "https://${var.hostname}"
}

output "api_url" {
  value = var.api_hostname == null ? null : "https://${var.api_hostname}"
}

output "service_clients" {
  description = "Per client: the Access service token headers and the OmniGraph bearer token to send on api_hostname."
  sensitive   = true
  value = {
    for name, actor in var.service_clients : name => {
      actor                   = actor
      cf_access_client_id     = try(cloudflare_zero_trust_access_service_token.client[name].client_id, null)
      cf_access_client_secret = try(cloudflare_zero_trust_access_service_token.client[name].client_secret, null)
      bearer_token            = random_password.actor_token[actor].result
    }
  }
}

output "tokens_json" {
  description = "Contents of /etc/omnigraph/tokens.json; push after adding or removing actors."
  sensitive   = true
  value       = local.tokens_json
}

output "caddyfile" {
  description = "Contents of /etc/omnigraph/Caddyfile; push after adding or removing users."
  sensitive   = true
  value       = local.caddyfile
}

output "compose" {
  description = "Rendered /etc/omnigraph/compose.yaml. user_data is only read at first boot; push changes with: terragrunt output -raw compose | ssh root@<droplet> 'cat > /etc/omnigraph/compose.yaml && cd /etc/omnigraph && docker compose --profile serve up -d'"
  value       = local.compose
}
