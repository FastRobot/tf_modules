# Minimal set of variables with some sane defaults for a tiny ELK setup
variable "name" {}
variable "namespace" {}
variable "environment" {}
variable "dns_zone_id" {}
variable "vpc_id" {}
variable "es_subnet_ids" {}
variable "logstash_subnet" {}

variable "allow_ssh_cidrs" {
  default = ["0.0.0.0/0"]
  type    = list(any)
}

variable "allow_logstash_cidrs" {
  default = ["0.0.0.0/0"]
  type    = list(any)
}

variable "create_iam_service_linked_role" {
  type        = bool
  default     = true
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info"
}

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

variable "protect_against_termination" {
  default     = "false"
  description = "prevent the logstash relay instance from being deleted"
}
