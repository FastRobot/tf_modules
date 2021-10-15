
locals {
  # array of CIDRs, started including ipv6 so I have to filter it out
  github_hook_cidrs = [
    for h in data.github_ip_ranges.gh.hooks : h if length(split(":", h)) == 1
  ]
  # https://github.com/hashicorp/terraform/issues/22405 showed me this jsonencode trick.
  # otherwise you run afoul of Inconsistent conditional result types
  alb_authenticate_oidc = alltrue([
    var.auth0_domain != "",
    var.auth0_client_id != "",
    var.auth0_client_secret != ""]) ? jsonencode({
    issuer                              = "${var.auth0_domain}/"
    token_endpoint                      = "${var.auth0_domain}/oauth/token"
    user_info_endpoint                  = "${var.auth0_domain}/userinfo"
    authorization_endpoint              = "${var.auth0_domain}/authorize"
    authentication_request_extra_params = {}
    client_id                           = var.auth0_client_id
    client_secret                       = var.auth0_client_secret # but really, get it from SSM
  }) : jsonencode({})
}

//data "aws_ssm_parameter" "webhook" {
//  name = "/atlantis/webhook/secret"
//}
//
//data "aws_ssm_parameter" "token" {
//  name = "/atlantis/github/user/token"
//}

module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "3.3.0"
  # insert the 18 required variables here
  atlantis_hide_prev_plan_comments = true
  alb_authenticate_oidc            = jsondecode(local.alb_authenticate_oidc)
  alb_drop_invalid_header_fields   = var.alb_drop_invalid_header_fields
  alb_ingress_cidr_blocks          = var.alb_ingress_cidr_blocks
  allow_unauthenticated_access     = true # allows for some unauthed access
  allow_github_webhooks            = true # just the github webhook ips
  allow_repo_config                = var.allow_repo_config
  custom_environment_variables     = var.custom_environment_variables
  ecs_container_insights           = true
  ecs_fargate_spot                 = true
  ecs_service_assign_public_ip = var.ecs_service_assign_public_ip
  github_webhooks_cidr_blocks      = local.github_hook_cidrs
  atlantis_github_user             = var.atlantis_github_user
  atlantis_github_user_token       = var.atlantis_github_user_token
  atlantis_image                   = var.atlantis_image
  #atlantis_github_webhook_secret = data.aws_ssm_parameter.webhook.value
  atlantis_repo_allowlist = var.repo_allowlist
  public_subnet_ids       = var.public_subnet_ids
  private_subnet_ids      = var.private_subnet_ids
  policies_arn            = var.policies_arn
  route53_zone_name       = var.route53_zone_name
  vpc_id                  = var.vpc_id
}

data "github_ip_ranges" "gh" {}
