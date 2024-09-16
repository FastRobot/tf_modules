## prometheus ecs IAM
# First, the roles needed for the prom scraper ecs tasks
resource "aws_iam_role" "prom-scraper-app-role" {
  name               = "${local.full_name}-prom-srv-ecs-app-role"
  assume_role_policy = data.aws_iam_policy_document.prom_ecs_task_assume_policy.json
}

resource "aws_iam_role" "prom-scraper-task-execution-role" {
  name               = "${local.full_name}-prom-srv-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.prom_ecs_task_assume_policy.json
}

# Attach some policies, managed and not, to the app role
resource "aws_iam_role_policy_attachment" "prom-generic" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ])
  policy_arn = each.value
  role       = aws_iam_role.prom-scraper-app-role.name
}

resource "aws_iam_role_policy_attachment" "prom-generic-writer" {
  policy_arn = aws_iam_policy.prom_writer.arn
  role       = aws_iam_role.prom-scraper-app-role.name
}

resource "aws_iam_role_policy_attachment" "prom-generic-discovery" {
  policy_arn = aws_iam_policy.prom_stack_discovery.arn
  role       = aws_iam_role.prom-scraper-app-role.name
}

# this attachment is for the ECS agent
resource "aws_iam_role_policy_attachment" "attach_custom_to_task_execution" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ])
  policy_arn = each.value
  role       = aws_iam_role.prom-scraper-task-execution-role.name
}

data "aws_iam_policy_document" "prom_ecs_task_assume_policy" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "prom_stack_discovery" {
  name   = "${local.full_name}-prom-ecs-task-discovery-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.prom_custom_task_policy.json
}

data "aws_iam_policy_document" "prom_custom_task_policy" {
  statement {
    sid       = "AllowReadingTagsInstancesRegionsFromEC2"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]
  }

  statement {
    sid       = "AllowReadingResourcesForTags"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["tag:GetResources"]
  }
}

resource "aws_iam_policy" "prom_writer" {
  name   = "${local.full_name}-prom-ecs-task-writer-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.prom_task_aps_write.json
}

data "aws_iam_policy_document" "prom_task_aps_write" {
  statement {
    sid       = "WritePrometheusMetrics"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "aps:RemoteWrite",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]
  }

  statement {
    sid       = "SSMGet"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ssm:GetParameter"]
  }

  statement {
    sid       = "AllowServiceDiscovery"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["servicediscovery:*"]
  }
  statement {
    sid       = "AllowPromEFS"
    effect    = "Allow"
    resources = [aws_efs_file_system.prom_service_storage.arn]
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRoot"
    ]
  }
}
