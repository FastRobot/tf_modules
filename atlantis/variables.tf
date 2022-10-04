
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
variable "atlantis_github_user_token_ssm_path" {}
variable "atlantis_github_organization" {}

variable "atlantis_image" {
  default = ""
}

variable "auth0_domain" {
  description = "eg https://something.auth0.com, no trailing slash"
  type        = string
  default     = ""
}

variable "auth0_client_id" {
  default = ""
}
variable "auth0_client_secret_ssm_path" {
  default = ""
}

variable "create_github_repository_webhook" {
  default = false
  type    = bool
}

variable "custom_environment_variables" {
  default = []
  type = list(object({
    name  = string
    value = string
  }))
}


variable "custom_environment_secrets" {
  description = "List of additional secrets the container will use (list should contain maps with `name` and `valueFrom`)"
  type = list(object(
    {
      name      = string
      valueFrom = string
    }
  ))
  default = []
}

variable "efs_file_system_encrypted" {
  type    = bool
  default = false
}

variable "environment" {
  description = "phase of lifecycle of stack, eg dev, prod"
  type        = string
}

# ECS Service / Task
variable "ecs_fargate_spot" {
  default = true
}

variable "ecs_service_assign_public_ip" {
  description = "Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)"
  type        = bool
  default     = false
}

variable "ecs_service_platform_version" {
  description = "The platform version on which to run your service"
  type        = string
  default     = "LATEST"
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

variable "policies_arn" {
  type    = list(string)
  default = null
}

variable "repo_allowlist" {
  description = "array of repo wildcards"
  type        = list(any)
}

variable "route53_zone_name" {}

variable "vpc_id" {
}
