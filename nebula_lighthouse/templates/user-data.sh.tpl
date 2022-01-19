#!/bin/bash

set -eu

NEB=/opt/nebula

mkdir $NEB

wget https://github.com/slackhq/nebula/releases/download/v1.5.2/nebula-linux-amd64.tar.gz -O $NEB/nebula-linux-amd64.tar.gz

tar -C $NEB -xvf $NEB/nebula-linux-amd64.tar.gz

# make a host key for the in-nebula sshd interface to use
ssh-keygen -t ed25519 -f $NEB/ssh_host_ed25519_key -N "" < /dev/null

echo '${nebula_config_yaml}' > $NEB/config.yml

# open up the firewall
ufw allow 4242/udp
ufw allow 22/tcp

cat > /etc/systemd/system/nebula.service <<EOService
[Unit]
Description=nebula
Wants=basic.target
After=basic.target network.target
Before=sshd.service

[Service]
SyslogIdentifier=nebula
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=$NEB/nebula -config $NEB/config.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOService

# and setup the service
chmod 644 /etc/systemd/system/nebula.service
systemctl daemon-reload
systemctl enable nebula.service
systemctl start nebula.service
systemctl status nebula.service

echo "Finished setting up lighthouse"
