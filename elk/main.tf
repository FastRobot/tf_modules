
resource "random_password" "kibana" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "elk" {
  source                  = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git//?ref=0.30.0"
  name                    = "elk"
  namespace               = "fr"
  environment             = var.environment
  dns_zone_id             = "Z14EN2YD427LRQ"
  security_groups         = [module.elk_sg.id]
  vpc_id                  = var.vpc_id
  subnet_ids              = [var.es_subnet_ids]
  zone_awareness_enabled  = false
  availability_zone_count = 1
  elasticsearch_version   = "7.4"
  instance_type           = "t2.small.elasticsearch"
  instance_count          = 1
  ebs_volume_size         = 10
  #iam_role_arns           = ["arn:aws:iam::XXXXXXXXX:role/ops", "arn:aws:iam::XXXXXXXXX:role/dev"]
  #iam_actions             = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost"]
  encrypt_at_rest_enabled                                  = false
  kibana_subdomain_name                                    = "kibana-es"
  advanced_security_options_internal_user_database_enabled = true
  advanced_security_options_master_user_name               = "admin"
  advanced_security_options_master_user_password           = random_password.kibana.result
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

}