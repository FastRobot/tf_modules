# Terraform modules by FastRobot

This is a collection of modules in use by FastRobot. We typically call them 
via `terragrunt`. Each top-level directory is its own self-contained module.

## Modules

* `elk` - stands up an AWS ES endpoint and an instance running logstash
* `zitadel_oidc_app` - a ZITADEL project, OIDC application, users and grants
* `tailscale_tailnet` - tailnet policy document and tailnet-wide settings