locals {
  create_amp        = alltrue([var.enable, var.enable_amp])
  create_prometheus = alltrue([var.enable, var.enable_prometheus])
  create_grafana    = alltrue([var.enable, var.enable_grafana_managed])
  full_name         = "${var.namespace}-${var.name}-${var.environment}"
  tags = {
    Environment = var.environment
    tf_module   = "FastRobot/tf_modules//monitoring"
  }
}

# workspace to remote_write to from our ECS task
resource "aws_prometheus_workspace" "prom" {
  count = local.create_amp ? 1 : 0
  alias = local.full_name
  tags  = merge(local.tags, { instance_index = count.index })
}

# some rules for the managed workspace
resource "aws_prometheus_rule_group_namespace" "prom-rules" {
  for_each     = var.rule_groups
  data         = each.value
  name         = each.key
  workspace_id = aws_prometheus_workspace.prom[0].id
}

# some alerts for the managed workspace
resource "aws_prometheus_alert_manager_definition" "prom-alerts" {
  for_each     = var.alerts
  definition   = each.value
  workspace_id = aws_prometheus_workspace.prom[0].id
}
