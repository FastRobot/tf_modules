variable "name" {}
variable "namespace" {}
variable "environment" {}
variable "vpc_id" {}
variable "subnets" {
  type        = list(string)
  description = "subnets to launch ASG ec2 instances into"
}
variable "keypair" {}

variable "include_ssm" {
  default     = true
  description = "should ec2 instances get AmazonSSMManagedInstanceCore"
}

variable "ec2_sgs" {
  type        = list(string)
  description = "list of security groups to apply to the ec2 instances, think I can add more later per task"
}