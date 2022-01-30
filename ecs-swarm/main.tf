locals {
  prefix = "${var.namespace}-${var.environment}-${var.name}"
  tags = {
    env = var.environment
  }
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 3.4"

  name               = local.prefix
  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy = [{
    capacity_provider = aws_ecs_capacity_provider.prov1.name # "FARGATE_SPOT"
    weight            = "1"
  }]

  tags = local.tags
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "prov1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
  }

}

#module "hello_world" {
#  source = "./service-hello-world"
#
#  cluster_id = module.ecs.ecs_cluster_id
#}

#----- ECS  Resources--------

# Going to try the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = local.prefix

  # Launch configuration
  lc_name   = local.prefix
  use_lc    = true
  create_lc = true

  image_id                  = data.aws_ami.amazon_linux_ecs.id
  instance_type             = "t2.micro"
  key_name                  = var.keypair
  security_groups           = [var.ec2_sgs]
  iam_instance_profile_name = aws_iam_instance_profile.this.id
  user_data = templatefile("${path.module}/templates/user-data.sh", {
    cluster_name = local.prefix
  })

  # Auto scaling group
  vpc_zone_identifier       = var.vpc_id # actually a list of subnets?
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 0 # we don't need them for the example
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.prefix
      propagate_at_launch = true
    },
  ]
}
