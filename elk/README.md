Module for installing an ELK stack
---------

This module spins up a AWS ElasticSearch endpoint (with internal kibana) plus an instance
to run logstash, ssh into and (eventually) proxy https to the kibana instance, along with the
appropriate security groups and IAM roles.

Inputs:
* vpc_id - the VPC in which this stack should live
* env - eg prod, stage, dev