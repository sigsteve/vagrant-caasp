#!/bin/bash

# Sudo this script

# Only run this after helm is installed 
touch /etc/systemd/system/helm-serve.service
cat >/etc/systemd/system/helm-serve.service <<EOF
[Unit]
Description=Helm Server
After=network.target

[Service]
User=sles
Restart=always
ExecStart=/usr/bin/helm serve

[Install]
WantedBy=multi-user.target
EOF

chmod 664 /etc/systemd/system/helm-serve.service
systemctl daemon-reload
sleep 1
systemctl start helm-serve
sleep 1
systemctl status helm-serve
sleep 2

sudo -u sles helm repo add local http://localhost:8879/charts
