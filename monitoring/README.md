# FR approved Monitoring stack
Conditionally sets up most mixes of:
* AWS Managed Prometheus backend (done)
* ECS fargate cluster (done)
  * Prometheus scraper task (done)
    * prometheus server (done)
    * prometheus-sdconfig-reloader (done)
  * node_exporter (daemonset) TODO
  * blackbox_exporter TODO
  * cadvisor (daemonset)
* Grafana
  * As an ecs service, maybe the cheapest?
  * via aws managed (default) (done)
  * via grafana cloud (fanciest, TODO)

We're using a AMP workspace as the central collection point for as many prometheus scrapers and their assorted exporters as you need. Your choice of grafana to view the collected metrics, plus cloudwatch, opensearch and any other service you want to configure.

## AMP Metric Retention
from https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html
> Metrics ingested into a workspace are stored for 150 days, and are then automatically deleted.

## AMP Ruler and AlertManager

This module also allows you to import a collection of yaml files as recording and alerting rules. We store these in terragrunt's live repo structure, each namespace as their own file, but you can pass any map that matches the structure as linked below.

* use https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-Ruler.html to pass a map of names of yaml strings in by namespace
* Expects prometheus standard rule and alert configuration 
* express the inputs however you like. Examples include templates through terragrunt or direct yaml conversion of hcl types in the calling module

Roughly based off of the structure from https://github.com/aws-samples/prometheus-for-ecs

## All the ways to run grafana
Depending on your complexity/scale/money tradeoffs you may have a clear preference for one of these grafana interfaces:

### Amazon Managed Grafana
https://aws.amazon.com/grafana/

This one is presumably the easiest to run going forward, as it's completely hosted by Amazon, but charges per user/month ($9 per admin, $5 per lesser user) so is probably best suited for very small teams. Because it's charger per user, you have to set up some form of enterprise auth, in this case I defaulted to AWS SSO and it was a complicated thing I didn't want to take on AND has org-wide implications I had to setup with manual intervention.   

### Open Source Grafana in ECS Fargate
Not working yet, but next, as I suspect it's the cheapest AND most flexible way to run the grafana I'm used to. I'd prefer to use grafana's auth-against-github to manage access and AFAICT you can't against AMG. 

### Grafana Cloud
https://grafana.com/products/cloud/

Free forever for 3 users, probably easy to point at the AMP/ES/opensearch. Will probably be cutting edge grafana so worth exploring the premium tier which is a dollar cheaper than AMG. Not working yet
