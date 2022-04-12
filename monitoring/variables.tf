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
  description = "should we make the ECS cluster and prometheus collector services"
  default     = true
  type        = bool
}

# start with AWS grafana, at $9/mo minimum, but would like to expand to
# enable_grafana_task - run grafana as an ECS task behind an ALB
# enable_grafana_cloud
variable "enable_grafana_managed" {
  description = "should we make the managed grafana resources"
  default     = true
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
