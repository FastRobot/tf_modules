#!/bin/bash
apt-get update
apt-get -y install docker.io docker-compose
systemctl enable --now docker

inst=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
NODE_NAME="${name}-$${inst}"

hostname "$NODE_NAME"
# to persist across reboots
echo $NODE_NAME > /etc/hostname

echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

# Add NODE_NAME to hosts file
echo "`hostname -i` $NODE_NAME" >> /etc/hosts
