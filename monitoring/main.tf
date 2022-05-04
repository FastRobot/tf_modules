locals {
  create_amp        = alltrue([var.enable, var.enable_amp])
  create_prometheus = alltrue([var.enable, var.enable_prometheus])
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


resource "aws_efs_file_system" "prom_service_storage" {
  encrypted = true
  tags = {
    Name = "${local.full_name}-prometheus-config"
  }
}

resource "aws_efs_mount_target" "prom_service_storage" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.prom_service_storage.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.prom_efs_sg.id]
}

# define the prometheus config-reloader (from https://github.com/aws-samples/prometheus-for-ecs)
# This is the least hacky way I can find to get a templated prometheus.yml into the stock prometheus
# container task. The 4 variables in the environment control the frequency at which this sidecar task
# will check ParameterStore for a prometheus.yml
# this container will template configs onto a EFS mount shared with a prometheus server
module "reloader_container_def" {
  count = local.create_prometheus ? 1 : 0

  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name   = "${local.full_name}-prometheus-config-reloader"
  container_image  = "public.ecr.aws/awsvijisarathy/prometheus-sdconfig-reloader:4.0"
  container_memory = 128 # tiny  process, tiny memory
  container_cpu    = 10
  user = "root"
  map_environment = {
    CONFIG_FILE_DIR                     = "/etc/config"
    CONFIG_RELOAD_FREQUENCY             = 60
    PROMETHEUS_CONFIG_PARAMETER_NAME    = "/${var.environment}/ECS-Prometheus-Configuration"
    DISCOVERY_NAMESPACES_PARAMETER_NAME = "/${var.environment}/ECS-ServiceDiscovery-Namespaces"
    AWS_REGION                          = data.aws_region.current.name
  }
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/Prometheus"
      awslogs-create-group  = true
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "${local.full_name}-reloader"
    }
  }
  mount_points = [
    {
      containerPath = "/etc/config"
      sourceVolume  = "${local.full_name}-prometheus-config"
      readOnly      = false
    }
  ]
}

resource "aws_ssm_parameter" "prom_config" {
  name  = "/${var.environment}/ECS-Prometheus-Configuration"
  type  = "String"
  value = replace(var.prometheus_config, "REMOTE_WRITE_URL", "${aws_prometheus_workspace.prom[0].prometheus_endpoint}api/v1/remote_write")
}

resource "aws_ssm_parameter" "prom_sd_ns" {
  name  = "/${var.environment}/ECS-ServiceDiscovery-Namespaces"
  type  = "String"
  value = "ecs-services"
}

# define the prometheus scraper container
# this container will scrape various prometheus exporters, then remote_write all data to the AMP prometheus endpoint
module "prometheus_container_def" {
  count = local.create_prometheus ? 1 : 0

  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name   = "${local.full_name}-prometheus"
  container_image  = var.prometheus_image
  container_memory = var.prometheus_container_memory
  container_cpu    = var.prometheus_container_cpu
  user = "root"
  port_mappings = [
    {
      containerPort = 9090
      hostPort      = 9090 # ?maybe?
      protocol      = "tcp"
    }
  ]
  command = [
    "--storage.tsdb.retention.time=15d",
    "--config.file=/etc/config/prometheus.yaml",
    "--storage.tsdb.path=/data",
    "--web.console.libraries=/etc/prometheus/console_libraries",
    "--web.console.templates=/etc/prometheus/consoles",
    "--web.enable-lifecycle"
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/Prometheus"
      awslogs-create-group  = true
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "${local.full_name}-prometheus"
    }
  }
  mount_points = [
    {
      containerPath = "/etc/config"
      sourceVolume  = "${local.full_name}-prometheus-config"
      readOnly      = true
    },
    {
      containerPath = "/data"
      sourceVolume  = "${local.full_name}-prometheus-data"
      readOnly      = false
    }
  ]
  healthcheck = {
    command = [
      "CMD-SHELL",
      "wget http://localhost:9090/-/healthy -O /dev/null || exit 1"
    ]
    retries     = 2
    timeout     = 2
    interval    = 10
    startPeriod = 10
  }
  container_depends_on = [
    {
      containerName = "${local.full_name}-prometheus-config-reloader"
      condition     = "START"
    }
  ]
}

# join all above containers into a single task
resource "aws_ecs_task_definition" "prom_stack" {
  count = local.create_prometheus ? 1 : 0
  container_definitions = jsonencode([
    module.reloader_container_def[0].json_map_object,
    module.prometheus_container_def[0].json_map_object
  ])
  cpu                      = 256
  memory                   = 512
  family                   = "${local.full_name}-prometheus-stack"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.prom-scraper-app-role.arn            # perms for the actual prom scraper
  execution_role_arn       = aws_iam_role.prom-scraper-task-execution-role.arn # perms for the ecs agent to launch the containers
  volume {
    name = "${local.full_name}-prometheus-config"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.prom_service_storage.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
    }
  }
  volume {
    # without any other identifiers, this becomes an ephemeral volume, which is fine cause we're remote-writing data to AMP
    name = "${local.full_name}-prometheus-data"
  }
}

resource "aws_ecs_service" "prom" {
  name                               = "${local.full_name}-prometheus-scraper"
  count                              = local.create_prometheus ? 1 : 0
  cluster                            = module.ecs[0].ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.prom_stack[0].arn
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  launch_type                        = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.prom_ecs_sg[0].id]
    assign_public_ip = false
  }
}
