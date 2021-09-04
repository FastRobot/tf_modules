
locals {
  webhook_url = "https://atlantis.${var.route53_zone_name}/events"
  webhook_secret = module.atlantis.webhook_secret
}

//data github_repository "repo" {
//  for_each = toset(var.atlantis_allowed_repo_names)
//  full_name = "${var.atlantis_github_organization}/${each.key}"
//}

resource "github_repository_webhook" "this" {
  count = var.create_github_repository_webhook ? length(var.atlantis_allowed_repo_names) : 0

  repository = var.atlantis_allowed_repo_names[count.index]

  configuration {
    url          = local.webhook_url
    content_type = "application/json"
    insecure_ssl = false
    secret       = local.webhook_secret
  }

  events = [
    "issue_comment",
    "pull_request",
    "pull_request_review",
    "pull_request_review_comment",
  ]
}
