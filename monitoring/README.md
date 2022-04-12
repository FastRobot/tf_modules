# FR approved Monitoring stack
Sets up:
* AWS Managed Prometheus backend (done)
* ECS cluster
  * Prometheus task
    * prometheus server
    * prometheus-sdconfig-reloader
  * node_exporter (daemonset)
  * blackbox
  * cadvisor (daemonset)
  * grafana (optional!)
* Grafana
  * in ecs, cheapest?
  * via aws managed (default)
  * via grafana cloud (fanciest)

## AMP Ruler and AlertManager
* use https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-Ruler.html to pass a map of names of yaml strings in by namespace
* Expects prometheus standard rule and alert configuration 
* express the inputs however you like. Examples include templates through terragrunt or direct yaml conversion of hcl types in the calling module


Roughly based off of the structure from https://github.com/aws-samples/prometheus-for-ecs

# Developing for
