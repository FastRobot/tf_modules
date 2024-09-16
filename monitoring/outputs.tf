output "prometheus_endpoint" {
  value = aws_prometheus_workspace.prom[0].prometheus_endpoint
}

output "prometheus_endpoint_remote_write" {
  value = "${aws_prometheus_workspace.prom[0].prometheus_endpoint}api/v1/remote_write"
}

output "prometheus_endpoint_query" {
  value = "${aws_prometheus_workspace.prom[0].prometheus_endpoint}api/v1/query"
}

output "prometheus_arn" {
  value = aws_prometheus_workspace.prom[*].arn
}

output "grafana_managed_endpoint" {
  value = [for ws in aws_grafana_workspace.grafana_managed[*] : "https://${ws.endpoint}"]
}

# not yet supported?
#output "grafana_managed_version" {
#  value = aws_grafana_workspace.grafana_managed[*].version
#}
