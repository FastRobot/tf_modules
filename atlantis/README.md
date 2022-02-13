## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.52.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 4.13.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_atlantis"></a> [atlantis](#module\_atlantis) | terraform-aws-modules/atlantis/aws | 3.3.0 |

## Resources

| Name | Type |
|------|------|
| [github_repository_webhook.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [aws_ssm_parameter.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [github_ip_ranges.gh](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_drop_invalid_header_fields"></a> [alb\_drop\_invalid\_header\_fields](#input\_alb\_drop\_invalid\_header\_fields) | n/a | `bool` | `true` | no |
| <a name="input_alb_ingress_cidr_blocks"></a> [alb\_ingress\_cidr\_blocks](#input\_alb\_ingress\_cidr\_blocks) | n/a | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_alb_log_bucket_name"></a> [alb\_log\_bucket\_name](#input\_alb\_log\_bucket\_name) | S3 bucket (externally created) for storing load balancer access logs. Required if alb\_logging\_enabled is true. | `string` | `""` | no |
| <a name="input_alb_log_location_prefix"></a> [alb\_log\_location\_prefix](#input\_alb\_log\_location\_prefix) | S3 prefix within the log\_bucket\_name under which logs are stored. | `string` | `""` | no |
| <a name="input_alb_logging_enabled"></a> [alb\_logging\_enabled](#input\_alb\_logging\_enabled) | Controls if the ALB will log requests to S3. | `bool` | `false` | no |
| <a name="input_allow_repo_config"></a> [allow\_repo\_config](#input\_allow\_repo\_config) | When true allows the use of atlantis.yaml config files within the source repos. | `string` | `"false"` | no |
| <a name="input_atlantis_allowed_repo_names"></a> [atlantis\_allowed\_repo\_names](#input\_atlantis\_allowed\_repo\_names) | Git repositories where webhook should be created | `list(string)` | `[]` | no |
| <a name="input_atlantis_github_organization"></a> [atlantis\_github\_organization](#input\_atlantis\_github\_organization) | n/a | `any` | n/a | yes |
| <a name="input_atlantis_github_user"></a> [atlantis\_github\_user](#input\_atlantis\_github\_user) | n/a | `any` | n/a | yes |
| <a name="input_atlantis_github_user_token"></a> [atlantis\_github\_user\_token](#input\_atlantis\_github\_user\_token) | n/a | `string` | `""` | no |
| <a name="input_atlantis_github_user_token_name"></a> [atlantis\_github\_user\_token\_name](#input\_atlantis\_github\_user\_token\_name) | optional, assumes you already placed the secret there | `string` | `""` | no |
| <a name="input_atlantis_image"></a> [atlantis\_image](#input\_atlantis\_image) | n/a | `string` | `""` | no |
| <a name="input_auth0_client_id"></a> [auth0\_client\_id](#input\_auth0\_client\_id) | n/a | `string` | `""` | no |
| <a name="input_auth0_client_secret"></a> [auth0\_client\_secret](#input\_auth0\_client\_secret) | n/a | `string` | `""` | no |
| <a name="input_auth0_domain"></a> [auth0\_domain](#input\_auth0\_domain) | eg https://something.auth0.com, no trailing slash | `string` | `""` | no |
| <a name="input_create_github_repository_webhook"></a> [create\_github\_repository\_webhook](#input\_create\_github\_repository\_webhook) | n/a | `bool` | `false` | no |
| <a name="input_custom_environment_secrets"></a> [custom\_environment\_secrets](#input\_custom\_environment\_secrets) | List of additional secrets the container will use (list should contain maps with `name` and `valueFrom`) | <pre>list(object(<br>    {<br>      name      = string<br>      valueFrom = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_custom_environment_variables"></a> [custom\_environment\_variables](#input\_custom\_environment\_variables) | n/a | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_ecs_fargate_spot"></a> [ecs\_fargate\_spot](#input\_ecs\_fargate\_spot) | ECS Service / Task | `bool` | `true` | no |
| <a name="input_ecs_service_assign_public_ip"></a> [ecs\_service\_assign\_public\_ip](#input\_ecs\_service\_assign\_public\_ip) | Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html) | `bool` | `false` | no |
| <a name="input_ecs_service_platform_version"></a> [ecs\_service\_platform\_version](#input\_ecs\_service\_platform\_version) | The platform version on which to run your service | `string` | `"LATEST"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | phase of lifecycle of stack, eg dev, prod | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | used to name some resources, urls | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | two letter code used to namespace all resources | `string` | n/a | yes |
| <a name="input_policies_arn"></a> [policies\_arn](#input\_policies\_arn) | n/a | `list(string)` | `null` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_repo_allowlist"></a> [repo\_allowlist](#input\_repo\_allowlist) | array of repo wildcards | `list(any)` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | n/a | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_atlantis_url"></a> [atlantis\_url](#output\_atlantis\_url) | n/a |
