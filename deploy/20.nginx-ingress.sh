#!/bin/bash
source /vagrant/caasp_env.conf
cat > /tmp/nginx-ingress-config-values.yaml << EOF
# Enable the creation of pod security policy
podSecurityPolicy:
  enabled: true

# Create a specific service account
serviceAccount:
  create: true
  name: nginx-ingress

# Publish services on port HTTP/80
# Publish services on port HTTPS/443
controller:
  service:
    externalIPs:
EOF
for NUM in $(seq 0 $(($NWORKERS-1)) ); do
    printf "      - 192.168.121.13${NUM}\n" >> /tmp/nginx-ingress-config-values.yaml
done

helm install --name nginx-ingress stable/nginx-ingress \
    --values /tmp/nginx-ingress-config-values.yaml
