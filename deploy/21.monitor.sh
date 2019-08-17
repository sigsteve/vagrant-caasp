#!/bin/bash

# TODO: 
#  * Fix and set the correct AppArmor annotations for Node-Exporter

CAASP_DOMAIN="$(sed -n 's/^\s*domain\s*= "\(.*\)".*$/\1/p' /vagrant/Vagrantfile)"
printf "Creating monitoring namespace\n"
kubectl create namespace monitoring

# copy the storage secret from default namespace to monitoring namespace
printf "Copy storage secret from default namespace to monitoring namespace\n"
kubectl get secret -o json $(kubectl get secret | awk '{print $1}' | grep nfs-client-provisioner) | \
  sed 's/"namespace": "default"/"namespace": "monitoring"/' | kubectl create -f -

# We will be using self signed certificates for prometheus and grafana, 
# we need to create that (the same certificate will be used for all three URLs)
printf "Createing self signed certificates for prometheus and grafana\n"
cat > /tmp/openssl.conf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
default_md = sha256
default_bits = 4096
prompt=no

[req_distinguished_name]
C = CZ
ST = CZ
L = Prague
O = example
OU = monitoring
CN = ${CAASP_DOMAIN}
emailAddress = admin@${CAASP_DOMAIN}

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = prometheus.${CAASP_DOMAIN}
DNS.2 = prometheus-alertmanager.${CAASP_DOMAIN}
DNS.3 = grafana.${CAASP_DOMAIN}
EOF

openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout /tmp/monitoring.key -out /tmp/monitoring.crt \
  -config /tmp/openssl.conf -extensions 'v3_req'

# Add the certificate as a secret to kubernetes
printf "Adding certificate as kubernetes secret\n"
kubectl create -n monitoring secret tls monitoring-tls  \
  --key  /tmp/monitoring.key \
  --cert /tmp/monitoring.crt

#####################################################
# Prometheus
######################################################
printf "Prometheus:\n"
cat > /tmp/prometheus-config-values.yaml << EOF
# Alertmanager configuration
alertmanager:
  enabled: true
  ingress:
    enabled: true
    hosts:
    -  prometheus-alertmanager.${CAASP_DOMAIN}
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    tls:
      - hosts:
        - prometheus-alertmanager.${CAASP_DOMAIN}
        secretName: monitoring-tls
  persistentVolume:
    enabled: true
    ## Use a StorageClass
    storageClass: nfs-client
    ## Create a PersistentVolumeClaim of 2Gi
    size: 2Gi
    ## Use an existing PersistentVolumeClaim (my-pvc)
    #existingClaim: prometheus-alert

alertmanagerFiles:
  alertmanager.yml:
    global:
      # The smarthost and SMTP sender used for mail notifications.
      smtp_from: alertmanager@${CAASP_DOMAIN}
      smtp_smarthost: smtp.${CAASP_DOMAIN}:587
      smtp_auth_username: admin@${CAASP_DOMAIN}
      smtp_auth_password: <password>
      smtp_require_tls: true

    route:
      # The labels by which incoming alerts are grouped together.
      group_by: ['node']

      # When a new group of alerts is created by an incoming alert, wait at
      # least 'group_wait' to send the initial notification.
      # This way ensures that you get multiple alerts for the same group that start
      # firing shortly after another are batched together on the first
      # notification.
      group_wait: 30s

      # When the first notification was sent, wait 'group_interval' to send a batch
      # of new alerts that started firing for that group.
      group_interval: 5m

      # If an alert has successfully been sent, wait 'repeat_interval' to
      # resend them.
      repeat_interval: 3h

      # A default receiver
      receiver: admin-example

    receivers:
    - name: 'admin-example'
      email_configs:
      - to: 'admin@${CAASP_DOMAIN}'

# Create a specific service account
serviceAccounts:
  nodeExporter:
    name: prometheus-node-exporter

# Allow scheduling of node-exporter on master nodes
nodeExporter:
  hostNetwork: false
  hostPID: false
  podSecurityPolicy:
    enabled: true
#    annotations:
#      seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default'
#      apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
#      seccomp.security.alpha.kubernetes.io/defaultProfileName: 'docker/default'
#      apparmor.security.beta.kubernetes.io/defaultProfileName: 'runtime/default'
  tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule

# Disable Pushgateway
pushgateway:
  enabled: false

# Prometheus configuration
server:
  ingress:
    enabled: true
    hosts:
    - prometheus.${CAASP_DOMAIN}
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    tls:
      - hosts:
        - prometheus.${CAASP_DOMAIN}
        secretName: monitoring-tls
  persistentVolume:
    enabled: true
    ## Use a StorageClass
    storageClass: nfs-client
    ## Create a PersistentVolumeClaim of 8Gi
    size: 8Gi
    ## Use an existing PersistentVolumeClaim (my-pvc)
    #existingClaim: prometheus
serverFiles:
  alerts: {}
  rules:
    groups:
    - name: caasp.node.rules
      rules:
      - alert: NodeIsNotReady
        expr: kube_node_status_condition{condition="Ready",status="false"} == 1
        for: 1m
        labels:
          severity: critical
        annotations:
          description: '{{ \$labels.node }} is not ready'
      - alert: NodeIsOutOfDisk
        expr: kube_node_status_condition{condition="OutOfDisk",status="true"} == 1
        labels:
          severity: critical
        annotations:
          description: '{{ \$labels.node }} has insufficient free disk space'
      - alert: NodeHasDiskPressure
        expr: kube_node_status_condition{condition="DiskPressure",status="true"} == 1
        labels:
          severity: warning
        annotations:
          description: '{{ \$labels.node }} has insufficient available disk space'
      - alert: NodeHasInsufficientMemory
        expr: kube_node_status_condition{condition="MemoryPressure",status="true"} == 1
        labels:
          severity: warning
        annotations:
          description: '{{ \$labels.node }} has insufficient available memory'
EOF
# We will be using basic authentication for Prometheus
# User: admin
# Password: linux
printf "  Adding basic authentication for Prometheus as kubernetes secret\n"
#it is important that the file name is 'auth', otherwise the ingress controller will return a 503
echo 'admin:$apr1$lCPTFdzB$Iubp1DzRYBDFjpJK72FOA0' > /tmp/auth
kubectl create secret generic -n monitoring prometheus-basic-auth --from-file=/tmp/auth
printf "  Installing Prometheus\n"
helm install --name prometheus stable/prometheus \
  --namespace monitoring \
  --values /tmp/prometheus-config-values.yaml

#####################################################
# Grafana
######################################################
printf "Grafana\n"
cat > /tmp/grafana-config-values.yaml << EOF
# Configure admin password
adminPassword: linux

# Ingress configuration
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - grafana.${CAASP_DOMAIN}
  tls:
    - hosts:
      - grafana.${CAASP_DOMAIN}
      secretName: monitoring-tls

# Configure persistent storage
persistence:
  enabled: true
  accessModes:
    - ReadWriteOnce
  ## Use a StorageClass
  storageClassName: nfs-client
  ## Create a PersistentVolumeClaim of 10Gi
  size: 10Gi
  ## Use an existing PersistentVolumeClaim (my-pvc)
  #existingClaim: grafana

# Enable sidecar for provisioning
sidecar:
  datasources:
    enabled: true
    label: grafana_datasource
  dashboards:
    enabled: true
    label: grafana_dashboard
EOF

# first of we create the datasource to be used for grafana
kubectl create -f /vagrant/deploy/grafana-datasources.yaml
# deploy the Grafana 
helm install --name grafana stable/grafana \
  --namespace monitoring \
  --values /tmp/grafana-config-values.yaml
# and a grafana dashboard as a ConfigMap
kubectl apply -f /vagrant/deploy/grafana-dashboards-caasp-cluster.yaml

######################################################
#                                                    #
#  Finished, display information                     #
#                                                    #
######################################################
clear
kubectl get pods --namespace monitoring
printf "\n You need to add the following to your /etc/hosts file:\n"
cat << EOF 
#vagrant-caasp4
192.168.121.111     grafana.${CAASP_DOMAIN} prometheus.${CAASP_DOMAIN} prometheus-alert.${CAASP_DOMAIN}


Then point your browser to the web interfaces

Grafana:
url: https://grafana.${CAASP_DOMAIN}
user: admin
pass: $(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)

Prometheus:
url: https://prometheus.${CAASP_DOMAIN}
user: admin
pass: linux

AlertManager:
url: https://prometheus-alertmanager.${CAASP_DOMAIN}
user: admin
pass: linux

Happy CaaSPing!
EOF
