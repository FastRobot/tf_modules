output "lighthouse_public_ip4" {
  value = digitalocean_droplet.nebula-lighthouse.ipv4_address
}

output "lighthouse_ipv6" {
  value = digitalocean_droplet.nebula-lighthouse.ipv6_address
}

output "lighthouse_floating_ip" {
  value = digitalocean_floating_ip.lighthouse_public_ip.ip_address
}