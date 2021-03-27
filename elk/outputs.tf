output "kibana_password" {
  value = random_password.kibana.result
}

output "logstash_host" {
  value = aws_instance.logstash.public_dns
}