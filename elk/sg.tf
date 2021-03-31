

module "elk_sg" {
  source = "cloudposse/security-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.1.4"
  rules = [
    {
      type        = "ingress"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "all"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  name        = "logstash"
  namespace   = var.namespace
  environment = var.environment
  vpc_id      = var.vpc_id
}

module "logstash_ssh_sg" {
  source = "cloudposse/security-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.1.4"
  rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allow_ssh_cidrs
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "all"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  name        = "logstash"
  namespace   = var.namespace
  environment = var.environment
  vpc_id      = var.vpc_id
}

output "talks_to_elk" {
  value = module.elk_sg.id
}

output "logstash_ssh" {
  value = module.logstash_ssh_sg.id
}