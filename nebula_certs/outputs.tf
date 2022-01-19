output "ca_crt_arn" {
  value = data.aws_ssm_parameter.ca_crt_base64.arn
}

output "ca_crt_base64" {
  value = data.aws_ssm_parameter.ca_crt_base64.value
  sensitive = true # it's actually not sensitive, but marking this false fails
}

output "ca_key_arn" {
  value = data.aws_ssm_parameter.ca_key_base64.arn
}

output "host_cert_ssm_paths" {
  value = { for h, values in var.host_map : h => "/nebula/${var.ca_name}/${values.hostname}"
  }
}