
variable "alb_drop_invalid_header_fields" {
  default = true
}

variable "alb_ingress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "alb_log_bucket_name" {
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if alb_logging_enabled is true."
  type        = string
  default     = ""
}

variable "alb_log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
  type        = string
  default     = ""
}

variable "alb_logging_enabled" {
  description = "Controls if the ALB will log requests to S3."
  type        = bool
  default     = false
}

variable "allow_repo_config" {
  description = "When true allows the use of atlantis.yaml config files within the source repos."
  type        = string
  default     = "false"
}

variable "atlantis_allowed_repo_names" {
  description = "Git repositories where webhook should be created"
  type        = list(string)
  default     = []
}

variable "atlantis_github_user" {}
variable "atlantis_github_user_token" {}
variable "atlantis_github_organization" {}

variable "auth0_domain" {
  description = "eg https://something.auth0.com, no trailing slash"
  type        = string
}

variable "auth0_client_id" {}
variable "auth0_client_secret" {}

variable "create_github_repository_webhook" {
  default = false
  type = bool
}

variable "environment" {
  description = "phase of lifecycle of stack, eg dev, prod"
  type        = string
}

variable "name" {
  description = "used to name some resources, urls"
  type        = string
}

variable "namespace" {
  description = "two letter code used to namespace all resources"
  type        = string
}

variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}

variable "repo_allowlist" {
  description = "array of repo wildcards"
  type        = list(any)
}

variable "route53_zone_name" {}

variable "vpc_id" {
}
