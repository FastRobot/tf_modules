# Minimal set of variables with some sane defaults for a tiny ELK setup
variable "name" {}
variable "namespace" {}
variable "environment" {}
variable "dns_zone_id" {}
variable "vpc_id" {}
variable "es_subnet_ids" {}
variable "logstash_subnet" {}
variable "make_public" {
  default = false
}
variable "aws_key_name" {}
variable "zone_awareness_enabled" {
  default = false
}
variable "availability_zone_count" {
  default = 1
}
variable "elasticsearch_version" {
  default = "7.4"
}
variable "instance_type" {
  default = "t2.small.elasticsearch"
}
variable "instance_count" {
  default = 1
}
variable "ebs_volume_size" {
  default = 10
}
#iam_role_arns           = ["arn:aws:iam::XXXXXXXXX:role/ops", "arn:aws:iam::XXXXXXXXX:role/dev"]
#iam_actions             = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost"]

variable "encrypt_at_rest_enabled" {
  default = false
}

variable "kibana_subdomain_name" {
  default = "kibana-es"
}

#advanced_options = {
#  "rest.action.multi.allow_explicit_index" = "true"
#}

variable "master_username" {
  default = "admin"
}
