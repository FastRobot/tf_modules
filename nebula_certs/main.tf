
resource "null_resource" "ca_certs" {
  triggers = {
    ca_name = var.ca_name
  }

  provisioner "local-exec" {
    # the command should have the effect of creating the key and storing it in the aws_ssm_parameter, runs once
    # changing the ca_name and deleting the old keys will re-generate these
    command = <<EOC
      nebula-cert ca -name '${var.ca_name}' -subnets '${var.ipv4_range}' \
       -out-crt ${path.module}/ca.crt -out-key ${path.module}/ca.key && \
      aws ssm put-parameter --name /nebula/${var.ca_name}/ca_crt --description "ca public key for ${var.ca_name} nebula" \
       --value "$(base64 -i ${path.module}/ca.crt)" --type String && \
      aws ssm put-parameter --name /nebula/${var.ca_name}/ca_key --description "ca private key for ${var.ca_name} nebula" \
       --value "$(base64 -i ${path.module}/ca.key)" --type SecureString
    EOC
  }
}

data "aws_ssm_parameter" "ca_crt_base64" {
  name       = "/nebula/${var.ca_name}/ca_crt"
  depends_on = [null_resource.ca_certs]
}

data "aws_ssm_parameter" "ca_key_base64" {
  name       = "/nebula/${var.ca_name}/ca_key"
  depends_on = [null_resource.ca_certs]
}

# I can't rely on the above files being on-disk every run, so I need to recreate a copy with a slightly different name for host signing
resource "local_file" "ca_crt" {
  content_base64 = data.aws_ssm_parameter.ca_crt_base64.value
  filename       = "${path.module}/stored_ca.crt"
}

resource "local_file" "ca_key" {
  content_base64 = data.aws_ssm_parameter.ca_key_base64.value
  filename       = "${path.module}/stored_ca.key"
}

# per host map
resource "null_resource" "host_certs" {
  for_each = var.host_map
  triggers = {
    serial = join("-", [each.key, each.value.serial])
  }
  depends_on = [local_file.ca_crt, local_file.ca_key]
  provisioner "local-exec" {
    # the command should have the effect of creating the key and storing it in the aws_ssm_parameter, runs once
    # changing the ca_name and deleting the old keys will re-generate these
    # ./nebula-cert sign -name "laptop" -ip "192.168.49.2/24" -groups "laptop,home,ssh"
    command = <<EOC
      nebula-cert sign -name '${each.value.hostname}' -ip '${each.value.ip}' -groups ${join(",", toset(each.value.groups))} \
       -ca-crt "${path.module}/stored_ca.crt" -ca-key "${path.module}/stored_ca.key" \
       -out-crt ${path.module}/${each.value.hostname}.crt -out-key ${path.module}/${each.value.hostname}.key && \
      aws ssm put-parameter --name /nebula/${var.ca_name}/${each.value.hostname}_crt \
       --description "${each.value.hostname} public key for ${var.ca_name} nebula" \
       --value "$(base64 -i ${path.module}/${each.value.hostname}.crt)" --type String && \
      aws ssm put-parameter --name /nebula/${var.ca_name}/${each.value.hostname}_key \
       --description "${each.value.hostname} private key for ${var.ca_name} nebula" \
       --value "$(base64 -i ${path.module}/${each.value.hostname}.key)" --type SecureString
    EOC
  }
}