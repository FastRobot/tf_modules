
resource "random_password" "kibana" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "logstash_profile" {
  name = "${var.namespace}-${var.environment}-logstash-profile"
  role = aws_iam_role.logstash.name
}

resource "aws_iam_role" "logstash" {
  name               = "${var.namespace}-${var.environment}-logstash-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

module "elk" {
  source                                                   = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git//?ref=0.30.0"
  name                                                     = "elk"
  namespace                                                = var.namespace
  environment                                              = var.environment
  create_iam_service_linked_role                           = var.create_iam_service_linked_role
  dns_zone_id                                              = var.dns_zone_id
  security_groups                                          = [module.elk_sg.id]
  vpc_id                                                   = var.vpc_id
  subnet_ids                                               = [var.es_subnet_ids]
  zone_awareness_enabled                                   = false
  availability_zone_count                                  = 1
  elasticsearch_version                                    = "7.9"
  instance_type                                            = var.instance_type
  instance_count                                           = 1
  ebs_volume_size                                          = 10
  iam_role_arns                                            = [aws_iam_role.logstash.arn]
  iam_actions                                              = ["es:ESHttp*"]
  encrypt_at_rest_enabled                                  = false
  kibana_subdomain_name                                    = var.kibana_subdomain_name
  advanced_security_options_internal_user_database_enabled = true
  advanced_security_options_master_user_name               = "admin"
  advanced_security_options_master_user_password           = random_password.kibana.result
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

}