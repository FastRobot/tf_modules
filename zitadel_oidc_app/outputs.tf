output "client_id" {
  description = "OIDC client ID to enter at the relying party."
  value       = zitadel_application_oidc.this.client_id
  sensitive   = true
}

output "client_secret" {
  description = "OIDC client secret to enter at the relying party. Read-only and sensitive, but it is stored in Terraform state."
  value       = zitadel_application_oidc.this.client_secret
  sensitive   = true
}

output "none_compliant" {
  description = "True when ZITADEL considers the OIDC configuration non-compliant. Must be false before attempting relying-party signup."
  value       = zitadel_application_oidc.this.none_compliant
}

output "compliance_problems" {
  description = "Detail behind none_compliant."
  value       = zitadel_application_oidc.this.compliance_problems
}

output "project_id" {
  description = "ID of the created ZITADEL project."
  value       = zitadel_project.this.id
}
