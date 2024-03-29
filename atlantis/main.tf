
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
    var.auth0_client_secret_ssm_path != ""]) ? jsonencode({
    issuer                              = "${var.auth0_domain}/"
    token_endpoint                      = "${var.auth0_domain}/oauth/token"
    user_info_endpoint                  = "${var.auth0_domain}/userinfo"
    authorization_endpoint              = "${var.auth0_domain}/authorize"
    authentication_request_extra_params = {}
    client_id                           = var.auth0_client_id
    client_secret                       = data.aws_ssm_parameter.auth0_client_secret[0].value
  }) : jsonencode({})
}

data "aws_ssm_parameter" "auth0_client_secret" {
  count = var.auth0_client_secret_ssm_path != "" ? 1 : 0
  name = var.auth0_client_secret_ssm_path
}

//data "aws_ssm_parameter" "webhook" {
//  name = "/atlantis/webhook/secret"
//}

data "aws_ssm_parameter" "github_token" {
  name = var.atlantis_github_user_token_ssm_path
}

data "aws_vpc" "atlantis" {
  id = var.vpc_id
}

module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "3.28.0"
  # insert the 18 required variables here
  atlantis_hide_prev_plan_comments = true
  alb_authenticate_oidc            = jsondecode(local.alb_authenticate_oidc)
  alb_drop_invalid_header_fields   = var.alb_drop_invalid_header_fields
  alb_ingress_cidr_blocks          = var.alb_ingress_cidr_blocks
  allow_unauthenticated_access     = true # allows for some unauthed access
  allow_github_webhooks            = true # just the github webhook ips
  allow_repo_config                = var.allow_repo_config
  cidr                             = data.aws_vpc.atlantis.cidr_block
  custom_environment_variables     = var.custom_environment_variables
  custom_environment_secrets       = var.custom_environment_secrets
  ecs_container_insights           = true
  ecs_fargate_spot                 = var.ecs_fargate_spot
  ecs_service_assign_public_ip     = var.ecs_service_assign_public_ip
  ecs_service_platform_version     = var.ecs_service_platform_version
  efs_file_system_encrypted        = var.efs_file_system_encrypted
  github_webhooks_cidr_blocks      = local.github_hook_cidrs
  atlantis_github_user             = var.atlantis_github_user
  atlantis_github_user_token       = data.aws_ssm_parameter.github_token.value
  atlantis_image                   = var.atlantis_image
  #atlantis_github_webhook_secret = data.aws_ssm_parameter.webhook.value
  atlantis_repo_allowlist = var.repo_allowlist
  public_subnet_ids       = var.public_subnet_ids
  private_subnet_ids      = var.private_subnet_ids
  policies_arn            = var.policies_arn
  route53_zone_name       = var.route53_zone_name
  user                    = "100:1000" # https://github.com/runatlantis/atlantis/issues/2221
  vpc_id                  = var.vpc_id
}

data "github_ip_ranges" "gh" {}
