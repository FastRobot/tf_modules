data "aws_region" "current" {}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

#output "subnet_cidr_blocks" {
#  value = [for s in data.aws_subnet.example : s.cidr_block]
#}
