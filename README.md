# Terraform modules by FastRobot

This is a collection of modules in use by FastRobot. We typically call them 
via `terragrunt`. Each top-level directory is its own self-contained module.

## Modules

* `cloudflare_account` - Cloudflare zones and the Zero Trust Google identity provider
* `elk` - stands up an AWS ES endpoint and an instance running logstash
* `omnigraph_droplet` - an OmniGraph server on a DigitalOcean droplet behind Cloudflare Tunnel + Access (Google login)