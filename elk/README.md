## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_elk"></a> [elk](#module\_elk) | git::https://github.com/cloudposse/terraform-aws-elasticsearch.git// | 0.30.0 |
| <a name="module_elk_sg"></a> [elk\_sg](#module\_elk\_sg) | cloudposse/security-group/aws | 0.1.4 |
| <a name="module_logstash_ssh_sg"></a> [logstash\_ssh\_sg](#module\_logstash\_ssh\_sg) | cloudposse/security-group/aws | 0.1.4 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.logstash_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.logstash](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.logstash](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [random_password.kibana](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu-focal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.instance-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_logstash_cidrs"></a> [allow\_logstash\_cidrs](#input\_allow\_logstash\_cidrs) | n/a | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_allow_ssh_cidrs"></a> [allow\_ssh\_cidrs](#input\_allow\_ssh\_cidrs) | n/a | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count) | n/a | `number` | `1` | no |
| <a name="input_aws_key_name"></a> [aws\_key\_name](#input\_aws\_key\_name) | n/a | `any` | n/a | yes |
| <a name="input_create_iam_service_linked_role"></a> [create\_iam\_service\_linked\_role](#input\_create\_iam\_service\_linked\_role) | Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info | `bool` | `true` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | n/a | `any` | n/a | yes |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | n/a | `number` | `10` | no |
| <a name="input_elasticsearch_version"></a> [elasticsearch\_version](#input\_elasticsearch\_version) | n/a | `string` | `"7.4"` | no |
| <a name="input_encrypt_at_rest_enabled"></a> [encrypt\_at\_rest\_enabled](#input\_encrypt\_at\_rest\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_es_subnet_ids"></a> [es\_subnet\_ids](#input\_es\_subnet\_ids) | n/a | `any` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | n/a | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t2.small.elasticsearch"` | no |
| <a name="input_kibana_subdomain_name"></a> [kibana\_subdomain\_name](#input\_kibana\_subdomain\_name) | n/a | `string` | `"kibana-es"` | no |
| <a name="input_logstash_subnet"></a> [logstash\_subnet](#input\_logstash\_subnet) | n/a | `any` | n/a | yes |
| <a name="input_make_public"></a> [make\_public](#input\_make\_public) | n/a | `bool` | `false` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | n/a | `string` | `"admin"` | no |
| <a name="input_name"></a> [name](#input\_name) | Minimal set of variables with some sane defaults for a tiny ELK setup | `any` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `any` | n/a | yes |
| <a name="input_protect_against_termination"></a> [protect\_against\_termination](#input\_protect\_against\_termination) | prevent the logstash relay instance from being deleted | `string` | `"false"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_logstash_host"></a> [logstash\_host](#output\_logstash\_host) | n/a |
| <a name="output_logstash_ssh"></a> [logstash\_ssh](#output\_logstash\_ssh) | n/a |
| <a name="output_talks_to_elk"></a> [talks\_to\_elk](#output\_talks\_to\_elk) | n/a |
