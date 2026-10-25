output "zone_ids" {
  description = "Zone ID by zone name."
  value       = { for name, zone in cloudflare_zone.this : name => zone.id }
}

output "name_servers" {
  description = "Cloudflare nameservers to set at each zone's registrar."
  value       = { for name, zone in cloudflare_zone.this : name => zone.name_servers }
}

output "google_identity_provider_id" {
  description = "ID of the Google identity provider, for an Access application's allowed_idps."
  value       = one(cloudflare_zero_trust_access_identity_provider.google[*].id)
}
