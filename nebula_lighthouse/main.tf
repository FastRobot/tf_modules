# Create a new SSH key
resource "digitalocean_ssh_key" "nebula" {
  name       = "DO nebula key"
  public_key = var.ssh_public_key
}

data "aws_ssm_parameter" "host_crt_base64" {
  name = "${var.host_crt_base64_arn}_crt"
}

data "aws_ssm_parameter" "host_key_base64" {
  name = "${var.host_key_base64_arn}_key"
}

locals {
  droplet_user_data = {
    nebula_config_yaml = yamlencode(local.nebula_config)
    nebula_version     = var.nebula_version
    authorized_keys    = var.nebula_sshd_authorized_keys_list
  }
  # this map gets yamlencoded as config.yml on disk, could still do further processing in user-data.sh
  nebula_config = {
    pki = {
      ca   = base64decode(var.ca_crt_base64)
      cert = base64decode(data.aws_ssm_parameter.host_crt_base64.value)
      key  = base64decode(data.aws_ssm_parameter.host_key_base64.value)
    }
    lighthouse = {
      am_lighthouse = true
      hosts         = []
    }
    listen = {
      host = "[::]"
      port = 4242
    }
    punchy = {
      punch = true
    }
    sshd = {
      enabled          = true
      listen           = "${var.nebula_lh_ip}:2222"
      host_key         = "./ssh_host_ed25519_key"
      authorized_users = var.nebula_sshd_authorized_keys_list
    }
    stats = {
      type     = "prometheus"
      listen   = "${var.nebula_lh_ip}:8080"
      path     = "/metrics"
      interval = "15s"
      message_metrics : true
      lighthouse_metrics : true
    }
    firewall = {
      conntrack = {
        tcp_timeout     = "12m"
        udp_timeout     = "3m"
        default_timeout = "10m"
        max_connections = "100000"
      }
      outbound = [
        {
          port  = "any"
          proto = "any"
          host  = "any"
      }]
      inbound = [
        {
          port  = "any"
          proto = "icmp"
          host  = "any"
        },
        {
          port   = "8080"
          proto  = "tcp"
          groups = var.nebula_monitoring_groups
        },
        {
          port   = "2222"
          proto  = "tcp"
          groups = var.nebula_mgmt_groups
        }
      ]
    }
  }
}

resource "digitalocean_floating_ip" "lighthouse_public_ip" {
  region = var.region
}

# Create a new Droplet using the SSH key
resource "digitalocean_droplet" "nebula-lighthouse" {
  image      = "ubuntu-20-04-x64"
  name       = "nebula-lighthouse"
  region     = var.region
  size       = "s-1vcpu-1gb"
  ssh_keys   = [digitalocean_ssh_key.nebula.fingerprint]
  ipv6       = true
  monitoring = true
  user_data  = templatefile("./templates/user-data.sh.tpl", local.droplet_user_data)
  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_firewall" "lh" {
  name        = "only-4242-and-ssh"
  droplet_ids = [digitalocean_droplet.nebula-lighthouse.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "4242"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "4242"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol = "icmp"
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_floating_ip_assignment" "lighthouse_ip_assignment" {
  ip_address = digitalocean_floating_ip.lighthouse_public_ip.ip_address
  droplet_id = digitalocean_droplet.nebula-lighthouse.id
}