# spin up a single instance to run logstash

data "aws_ami" "ubuntu-focal" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "logstash" {
  ami                         = data.aws_ami.ubuntu-focal.id
  associate_public_ip_address = var.make_public
  key_name                    = var.aws_key_name
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.logstash_profile.name
  security_groups             = [module.elk_sg.id]
  subnet_id                   = var.logstash_subnet
  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    name         = "logstash"
    elk_endpoint = module.elk.domain_endpoint
  })
}