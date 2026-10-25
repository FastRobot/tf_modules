# One droplet runs one OmniGraph server (the supported single-writer
# topology) plus Caddy and cloudflared. The droplet accepts no inbound
# traffic except optional SSH; the public path is the Cloudflare Tunnel.
#
# The cluster root lives on a separate block-storage volume, so the droplet
# can be rebuilt without touching graph data.

resource "digitalocean_ssh_key" "this" {
  for_each = { for i, key in var.ssh_public_keys : tostring(i) => key }

  name       = "${var.name}-${each.key}"
  public_key = each.value
}

resource "digitalocean_volume" "data" {
  region                  = var.region
  name                    = "${var.name}-data"
  size                    = var.volume_size_gb
  initial_filesystem_type = "ext4"
  description             = "OmniGraph cluster root"

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  compose = templatefile("${path.module}/templates/compose.yaml.tftpl", {
    omnigraph_image   = var.omnigraph_image
    caddy_image       = var.caddy_image
    cloudflared_image = var.cloudflared_image
  })

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    volume_name        = digitalocean_volume.data.name
    omnigraph_image    = var.omnigraph_image
    compose            = local.compose
    caddyfile          = local.caddyfile
    tokens_json        = local.tokens_json
    tunnel_token       = data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token
    registry_auth      = var.registry_auth
    tailscale_auth_key = var.tailscale_auth_key
    tailscale_tags     = join(",", var.tailscale_tags)
    hostname           = var.name
  })
}

resource "digitalocean_droplet" "this" {
  name       = var.name
  image      = var.droplet_image
  region     = var.region
  size       = var.size
  ssh_keys   = concat(var.ssh_key_fingerprints, [for key in digitalocean_ssh_key.this : key.fingerprint])
  volume_ids = [digitalocean_volume.data.id]
  ipv6       = true
  monitoring = true
  user_data  = local.user_data

  lifecycle {
    # user_data only seeds a new droplet; changing it would replace the
    # droplet, and with it the running writer. Push config and token changes
    # with the commands in the README instead.
    ignore_changes = [user_data]
  }
}

resource "digitalocean_firewall" "this" {
  name        = var.name
  droplet_ids = [digitalocean_droplet.this.id]

  dynamic "inbound_rule" {
    for_each = length(var.ssh_source_addresses) == 0 ? [] : [1]
    content {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = var.ssh_source_addresses
    }
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
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
