locals {
  create_ecs = alltrue([var.enable, anytrue([var.enable_grafana_ecs, var.enable_prometheus])])
  # also local.create_prometheus from main.tf
}

# ECS cluster for monitoring tasks
module "ecs" {
  count   = local.create_ecs ? 1 : 0
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"
  name    = "${local.full_name}-ecs"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = local.tags
}

# alternately, setup the cloudwatch agent to scrape and remote-write to AMP
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html

# define container definitions for a prometheus and sd sidecar and other exporters
# https://github.com/cloudposse/terraform-aws-ecs-container-definition



# combine multiple above defs into
# https://github.com/cloudposse/terraform-aws-ecs-alb-service-task
