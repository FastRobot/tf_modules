output "logstash_host" {
  value = aws_instance.logstash.public_dns
}
