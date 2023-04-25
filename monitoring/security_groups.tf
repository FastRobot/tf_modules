# misc security groups needed across the monitoring stack, they're so bulky I like to move them out of the way

# Security group for the ALB
resource "aws_security_group" "grafana_alb_sg" {
  count       = local.create_grafana_ecs ? 1 : 0
  name        = "${local.full_name}-grafana-alb-sg"
  description = "Allow traffic to the ALB created for the ${local.full_name} grafana service"
  vpc_id      = var.vpc_id

}

resource "aws_security_group_rule" "allow_outbound_grafana_ecs_alb_http_redirect_all" {
  count             = local.create_grafana_ecs ? 1 : 0
  security_group_id = aws_security_group.grafana_alb_sg[0].id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_outbound_grafana_ecs_alb_service_all" {
  count             = local.create_grafana_ecs ? 1 : 0
  security_group_id = aws_security_group.grafana_alb_sg[0].id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_outbound_grafana_ecs_alb_all" {
  count             = local.create_grafana_ecs ? 1 : 0
  security_group_id = aws_security_group.grafana_alb_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for the grafana ecs task
resource "aws_security_group" "grafana_ecs_sg" {
  count       = local.create_grafana_ecs ? 1 : 0
  name        = "${local.full_name}-grafana-ecs-sg"
  description = "Allow traffic to the ecs task created for the ${local.full_name} grafana service"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_grafana_ecs_http_all" {
  count             = local.create_grafana_ecs ? 1 : 0
  security_group_id = aws_security_group.grafana_ecs_sg[0].id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_outbound_grafana_ecs_all" {
  count             = local.create_grafana_ecs ? 1 : 0
  security_group_id = aws_security_group.grafana_ecs_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for the prometheus server ecs task
resource "aws_security_group" "prom_ecs_sg" {
  count       = local.create_prometheus ? 1 : 0
  name        = "${local.full_name}-grafana-ecs-sg"
  description = "Allow traffic to the ecs task created for the ${local.full_name} grafana service"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_prom_ecs_http_all" {
  count             = local.create_prometheus ? 1 : 0
  security_group_id = aws_security_group.prom_ecs_sg[0].id
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  # TODO lock this down to something much more restrictive, nothing needs api access but admins
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_outbound_prom_ecs_all" {
  count             = local.create_prometheus ? 1 : 0
  security_group_id = aws_security_group.prom_ecs_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "prom_efs_sg" {
  name        = "${local.full_name}-efs-sg"
  description = "Allow traffic to the prometheus EFS storage volume"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.prom_ecs_sg[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
