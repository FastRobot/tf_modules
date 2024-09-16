# Terraform modules by FastRobot

This is a collection of modules in use by FastRobot. We typically call them 
via `terragrunt`. Eventually we'll have some common utility modules but for now each top level dir is standalone and defaults to the cheapest possible way to accomplish a task. 

## Modules

* `atlantis` - opinionated wrapper for the official atlantis terraform module, setting up github webhooks and auth for selected repos, plus some ALB authentication schemes through OIDC providers.
* `elk` - stands up an AWS ES endpoint and an instance running logstash.
* `monitoring` - prometheus with various exporters as ecs tasks remote writing to an Amazon Managed Prometheus central collector, fronted by your choice of three grafanas, Amazon Managed Grafana, Grafana Cloud, Open Source Grafana as an ECS task
