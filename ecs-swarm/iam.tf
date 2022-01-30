locals {
  prefix = "${var.namespace}-${var.environment}-${var.name}"
  tags = {
    env = var.environment
  }
}

# instances need a role to allow them access to ECS
resource "aws_iam_role" "ecs" {
  name               = "${local.prefix}_ecs_instance_role"
  path               = "/ecs/"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# the ec2 service needs to be able to assume this role
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# role becomes a profile we can assign to instances
resource "aws_iam_instance_profile" "this" {
  name = "${var.name}_ecs_instance_profile"
  role = aws_iam_role.ecs.name
  tags = local.tags
}

# I bet we'll never run this in govcloud or china, but costs almost nothing to code against all three
data "aws_partition" "current" {}

# now attach as many policies as you need to the ecs role for ec2 instances
# instances need to be able to do basic ECS activities via this aws managed role
resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# While I don't yet use it, the SSM managed instance utilities could be useful and lets grant instances the core by default
resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  count = var.include_ssm ? 1 : 0

  role       = aws_iam_role.ecs.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# I really want to tighten this, but full cloudwatch logs access is a starting point
resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ecs.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
}