# Terraform modules by FastRobot

This is a collection of modules in use by FastRobot. We typically call them 
via `terragrunt`. Each top-level directory is its own self-contained module.

## Modules

* `elk` - stands up an AWS ES endpoint and an instance running logstash
* `nebula_lighthouse` - stands up a DigitalOcean droplet running a nebula lighthouse
* 