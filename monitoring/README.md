# FR approved Monitoring stack
Sets up:
* AWS Managed Prometheus backend (done)
* ECS cluster (done)
  * Prometheus scraper task (done)
    * prometheus server (done)
    * prometheus-sdconfig-reloader (done)
  * node_exporter (daemonset)
  * blackbox
  * cadvisor (daemonset)
  * grafana (optional!)
* Grafana
  * in ecs, cheapest?
  * via aws managed (default) (done)
  * via grafana cloud (fanciest)

## AMP Metric Retention
from https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html
> Metrics ingested into a workspace are stored for 150 days, and are then automatically deleted.

## AMP Ruler and AlertManager
* use https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-Ruler.html to pass a map of names of yaml strings in by namespace
* Expects prometheus standard rule and alert configuration 
* express the inputs however you like. Examples include templates through terragrunt or direct yaml conversion of hcl types in the calling module

No modules.

Roughly based off of the structure from https://github.com/aws-samples/prometheus-for-ecs

# Developing for
