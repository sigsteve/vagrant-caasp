#!/bin/bash

# Only run this after helm is installed 
sudo touch /etc/systemd/system/helm-serve.service
sudo cat >/etc/systemd/system/helm-serve.service <<EOF
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

sudo chmod 664 /etc/systemd/system/helm-serve.service
sudo systemctl daemon-reload
sudo systemctl start helm-serve
sudo systemctl status helm-serve


helm repo add local http://localhost:8879/charts
