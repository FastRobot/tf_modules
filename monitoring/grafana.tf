# all the grafana related tasks, doing any combination of
# 1) optionally configuring the Amazon Managed Grafana
#  * satisfies a desire to "keep everything in AWS"
#  * Free for 90 days, then $9/mo per admin (min 1) and $5/mo per read-only user (min 0)
# 2) optionally configuring an ECS task running `grafana/grafana-oss`
#  * update or rewrite of https://github.com/56kcloud/terraform-grafana
# 3) optionally configuring grafana cloud

locals {
  create_grafana_managed = alltrue([var.enable, var.enable_grafana_managed])
  create_grafana_ecs     = alltrue([var.enable, var.enable_grafana_ecs])

  # local.full_name is defined in main.tf
  # full_name         = "${var.namespace}-${var.name}-${var.environment}"
  # local.tags comes from main.tf
}

########################
# Amazon Managed Grafana
########################

resource "aws_grafana_workspace" "grafana_managed" {
  count = local.create_grafana_managed ? 1 : 0
  # required
  account_access_type      = var.grafana_managed_account_access_type
  authentication_providers = var.grafana_managed_authentication_providers
  permission_type          = var.grafana_managed_permission_type
  # optional
  data_sources              = var.grafana_managed_data_sources
  description               = "tf managed for ${local.full_name}"
  name                      = "${local.full_name}-grafana"
  notification_destinations = ["SNS"] # seems like the only possible value
  role_arn                  = aws_iam_role.grafana[0].arn
  stack_set_name            = local.full_name
}

resource "aws_iam_role" "grafana" {
  count              = local.create_grafana_managed ? 1 : 0
  name               = "${local.full_name}-grafana"
  assume_role_policy = data.aws_iam_policy_document.grafana-assume-policy-doc[0].json
}

data "aws_iam_policy_document" "grafana-assume-policy-doc" {
  count = local.create_grafana_managed ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    sid     = "AllowGrafanaService${var.environment}role"
    principals {
      identifiers = ["grafana.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "grafana" {
  count       = local.create_grafana_managed ? 1 : 0 # might expand that to also include creating grafana via ecs task
  name        = "${local.full_name}-grafana"
  description = "Policy for Managed Grafana"
  policy      = data.aws_iam_policy_document.grafana-service-access[0].json
}

data "aws_iam_policy_document" "grafana-service-access" {
  count = local.create_grafana_managed ? 1 : 0
  # AMP
  statement {
    sid    = "ListAllPrometheusWorkspaces"
    effect = "Allow"
    actions = [
      "aps:ListWorkspaces",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "PerPrometheusWorkspacesPermissions"
    effect = "Allow"
    actions = [
      "aps:DescribeWorkspace",
      "aps:QueryMetrics",
      "aps:GetLabels",
      "aps:GetSeries",
      "aps:GetMetricMetadata"
    ]
    resources = ["*"] # this can be tighter
  }
  # OpenSearch (formerly elasticsearch)
  statement {
    sid    = "OpenSearchList"
    effect = "Allow"
    actions = [
      "es:ESHttpGet",
      "es:DescribeElasticsearchDomains",
      "es:ListDomainNames"
    ]
    resources = ["*"]
  }
  statement {
    sid = "OpenSearchPost"
    actions = [
      "es:ESHttpPost"
    ]
    resources = [
      "arn:aws:es:*:*:domain/*/_msearch*",
      "arn:aws:es:*:*:domain/*/_opendistro/_ppl"
    ]
  }
  # SNS Alerting
  statement {
    sid       = "SNSPublish"
    actions   = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }
  # CloudWatch
  statement {
    sid = "AllowReadingMetricsFromCloudWatch"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData"
    ]
    resources = ["*"]
  }
  statement {
    sid = "AllowReadingLogsFromCloudWatch"
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid = "AllowReadingTagsInstancesRegionsFromEC2"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "AllowReadingResourcesForTags"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "grafana-service-attach" {
  count      = local.create_grafana_managed ? 1 : 0
  policy_arn = aws_iam_policy.grafana[0].arn
  role       = aws_iam_role.grafana[0].name
}

# made by hand the AWS SSO signup, created a user and
# created a grafana-admin group
# should make a grafana-reader group
# had to assign the new group to the account, gave it a bunch of iam admin stuff
# was making a aws-sso permission set

resource "aws_grafana_role_association" "aws_sso_admin_role" {
  count = local.create_grafana_managed ? 1 : 0
  role         = "ADMIN"
  group_ids    = [data.aws_identitystore_group.admins[0].group_id]
  workspace_id = aws_grafana_workspace.grafana_managed[0].id
}

data "aws_ssoadmin_instances" "internal" {
  count = local.create_grafana_managed ? 1 : 0
}

data "aws_identitystore_group" "admins" {
  count = local.create_grafana_managed ? 1 : 0
  identity_store_id = tolist(data.aws_ssoadmin_instances.internal[0].identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "grafana-admin"
  }
}


# regardless of which grafana methods we used, do the following
# load the datastores (did so manually from the UI, sucked)
# load some dashboards
# * cAdvisor with filtering for ECS cluster/task https://grafana.com/grafana/dashboards/15200

###########
# Grafana on ECS (open source, self hosted)
###########

module "grafana_ecs_container_definition" {
  count            = local.create_grafana_ecs ? 1 : 0
  source           = "registry.terraform.io/cloudposse/ecs-container-definition/aws"
  version          = "0.58.1"
  container_name   = "${local.full_name}-grafana"
  container_image  = var.grafana_ecs_container_image
  container_memory = var.grafana_ecs_container_memory
  secrets = [
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_ALLOW_SIGN_UP"
      name      = "GF_AUTH_GITHUB_ALLOW_SIGN_UP"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_ALLOWED_ORGANIZATIONS"
      name      = "GF_AUTH_GITHUB_ALLOWED_ORGANIZATIONS"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_API_URL"
      name      = "GF_AUTH_GITHUB_API_URL"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_AUTH_URL"
      name      = "GF_AUTH_GITHUB_AUTH_URL"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_CLIENT_ID"
      name      = "GF_AUTH_GITHUB_CLIENT_ID"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_CLIENT_SECRET"
      name      = "GF_AUTH_GITHUB_CLIENT_SECRET"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_ENABLED"
      name      = "GF_AUTH_GITHUB_ENABLED"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_SCOPES"
      name      = "GF_AUTH_GITHUB_SCOPES"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_AUTH_GITHUB_TOKEN_URL"
      name      = "GF_AUTH_GITHUB_TOKEN_URL"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_SERVER_ROOT_URL"
      name      = "GF_SERVER_ROOT_URL"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_SERVER_ENABLE_GZIP"
      name      = "GF_SERVER_ENABLE_GZIP"
    },
    {
      valueFrom = "/grafana/${local.full_name}/GF_DEFAULT_INSTANCE_NAME"
      name      = "GF_DEFAULT_INSTANCE_NAME"
    },
  ]
  port_mappings = [
    {
      containerPort = 3000
      hostPort      = 3000 # ?maybe?
      protocol      = "tcp"
    }
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/Prometheus"
      awslogs-create-group  = true
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "${local.full_name}-reloader"
    }
  }
}


module "grafana_ecs_alb_service_task" {
  count                              = local.create_grafana_ecs ? 1 : 0
  source                             = "registry.terraform.io/cloudposse/ecs-alb-service-task/aws"
  version                            = "0.64.0"
  namespace                          = var.namespace
  stage                              = var.environment
  name                               = var.name
  delimiter                          = "-"
  alb_security_group                 = aws_security_group.grafana_alb_sg[0].id
  container_definition_json          = module.grafana_ecs_container_definition[0].json_map_encoded_list
  ecs_cluster_arn                    = module.ecs[0].ecs_cluster_arn
  launch_type                        = var.grafana_ecs_launch_types
  vpc_id                             = var.vpc_id
  security_group_ids                 = [aws_security_group.grafana_ecs_sg[0].id]
  subnet_ids                         = var.private_subnet_ids
  tags                               = local.tags
  ignore_changes_task_definition     = false
  assign_public_ip                   = var.grafana_ecs_assign_public_ip
  propagate_tags                     = "SERVICE"
  deployment_minimum_healthy_percent = 0   # undeploy old task before new
  deployment_maximum_percent         = 100 # never run more
  deployment_controller_type         = "ECS"
  desired_count                      = 1
  task_memory                        = var.grafana_ecs_task_memory
  task_cpu                           = var.grafana_ecs_task_cpu
}
