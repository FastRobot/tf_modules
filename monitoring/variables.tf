variable "name" {
  description = "name for this monitoring stack"
  default     = "monitoring"
  type        = string
}

variable "namespace" {
  description = "2 letter code to prefix resources with"
  default     = "fr"
}

variable "environment" {
  default = "dev"
}

variable "enable" {
  description = "Create for-pay resources, setting to false will suppress all resources"
  default     = true
  type        = bool
}

variable "enable_amp" {
  description = "should we make the managed prometheus backend"
  default     = true
  type        = bool
}

variable "enable_prometheus" {
  description = "Make the ECS fargate cluster and prometheus collector services"
  default     = true
  type        = bool
}

# start with AWS grafana, at $9/mo minimum, but would like to expand to
# enable_grafana_task - run grafana as an ECS task behind an ALB
# enable_grafana_cloud
variable "enable_grafana_managed" {
  description = "Make the Amazaon Managed Grafana resources"
  default     = true
  type        = bool
}

variable "enable_grafana_ecs" {
  description = "Should we make an ECS fargate cluster to run OSS grafana resources"
  default     = false
  type        = bool
}
variable "rule_groups" {
  default = {
    basic = <<EOF
groups:
  - name: test
    rules:
    - record: metric:recording_rule
      expr: avg(rate(container_cpu_usage_seconds_total[5m]))
EOF
  }
  description = "A map of AMP-Ruler blocks, strings of yaml describing alerts and recording rules to create synthetic metrics"
  type        = map(any)
}

variable "alerts" {
  default     = {}
  description = "Route, inhibit, and silence alerts, named map of yaml string value"
  type        = map(any)
}

variable "sns_topic_arn" {
  default     = ""
  description = "The sns topic grafana attempts to publish to"
}

variable "public_subnet_ids" {
  description = "subnet_ids for public services, eg the ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "subnet_ids for private services"
  type        = list(string)
}

variable "grafana_ecs_assign_public_ip" {
  default = "false"
}

variable "grafana_ecs_container_image" {
  default     = "grafana/grafana-oss:8.4.6"
  type        = string
  description = "The image used to start the grafana container. Images in the Docker Hub registry available by default"
}

variable "grafana_ecs_container_memory" {
  default = "512"
}

variable "grafana_ecs_launch_types" {
  type    = string
  default = "FARGATE"
}

variable "grafana_ecs_task_cpu" {
  type    = number
  default = "128"
}

variable "grafana_ecs_task_memory" {
  type    = number
  default = "512"
}

variable "grafana_managed_account_access_type" {
  default = "CURRENT_ACCOUNT"
  type    = string
}

variable "grafana_managed_authentication_providers" {
  default     = ["AWS_SSO"]
  type        = set(string)
  description = "one or both of AWS_SSO, SAML"
}

variable "grafana_managed_permission_type" {
  default     = "SERVICE_MANAGED"
  type        = string
  description = "one of SERVICE_MANAGED or CUSTOMER_MANAGED"
}
variable "grafana_managed_data_sources" {
  default     = ["PROMETHEUS", "CLOUDWATCH"]
  type        = set(string)
  description = "The data sources for the workspace. Valid values are AMAZON_OPENSEARCH_SERVICE, CLOUDWATCH, PROMETHEUS, XRAY, TIMESTREAM, SITEWISE."
}

variable "prometheus_config" {
  type        = string
  description = "a prometheus config file passed in as one big string"
}

variable "prometheus_container_cpu" {
  default = "246" # quarter a vCpu, look to reduce later if we possible
}

variable "prometheus_container_memory" {
  default = "502"
}


variable "prometheus_image" {
  default = "quay.io/prometheus/prometheus:v2.35.0"
}

variable "vpc_id" {}
