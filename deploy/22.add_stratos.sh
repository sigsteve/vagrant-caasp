#!/bin/bash 
echo "Adding Stratos Console..."
cat > /tmp/stratos-values.yaml << EOF
# Tag for images - do not edit
consoleVersion: 2.6.1-9e13f7b0c-cap
dockerRegistrySecret: regsecret
# Specify default DB password
dbPassword: changeme
dbProvider: mysql
# Provide Proxy settings if required
#httpProxy: proxy.corp.net
#httpsProxy: proxy.corp.net
#noProxy: localhost
#ftpProxy: proxy.corp.net
#socksProxy: sock-proxy.corp.net
imagePullPolicy: IfNotPresent
# useLb is deprecated - use console.service.type
useLb: false
console:
  cookieDomain:
  # externalIP deprecated - use console.service.externalIPs
# externalIP: 127.0.0.1
  backendLogLevel: info
  ssoLogin: false
  ssoOptions:
  # Session Store Secret
  sessionStoreSecret:
  # Stratos Services
  service:
    annotations: []
    externalIPs: []
    loadBalancerIP:
    loadBalancerSourceRanges: []
    servicePort: 443
    # nodePort: 30000
    type: ClusterIP
    externalName:
    ingress:
      ## If true, Ingress will be created
      enabled: true

      ## Additional annotations
      annotations: {}

      ## Additional labels
      extraLabels: {}

      ## Host for the ingress
      # Defaults to console.[env.Domain] if env.Domain is set and host is not
      host: console.suselab.com

      # Name of secret containing TLS certificate
      secretName:

      # crt and key for TLS Certificate (this chart will create the secret based on these)
      tls:
        crt:
        key:

    http:
      enabled: true
      servicePort: 80
      # nodePort: 30001

  # Name of config map that provides the template files for user invitation emails
  templatesConfigMapName:

  # Email subject of the user invitation message 
  userInviteSubject: ~

  # Whether to perform the volume migration job on install/upgrade (migrate to secrets)
  migrateVolumes: true
  
  # Enable/disable Tech Preview
  techPreview: true

  # Use local admin user instead of UAA - set to a password to enable
  localAdminPassword: stratos

images:
  console: stratos-console
  proxy: stratos-jetstream
  postflight: stratos-postflight-job
  mariadb: stratos-mariadb

# Specify which storage class should be used for PVCs
storageClass: nfs-client
#consoleCert: |
#    -----BEGIN CERTIFICATE-----
#   MIIDXTCCAkWgAwIBAgIJAJooOiQWl1v1MA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
#   ...
#    -----END CERTIFICATE-----
#consoleCertKey: |
#    -----BEGIN PRIVATE KEY-----
#    MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkdgEAAoIBAQDV9+ySh0xZzM41
#    ...
#    -----END PRIVATE KEYE-----
# MariaDB chart configuration
mariadb:
  # Only required for creating the databases
  mariadbRootPassword: changeme
  adminUser: root
  # Credentials for user
  mariadbUser: console
  mariadbPassword: changeme
  mariadbDatabase: console
  usePassword: true
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
  persistence:
    enabled: true
    accessMode: ReadWriteOnce
    size: 1Gi
    storageClass: nfs-client
uaa:
  protocol: https://
  port: 
  host: 
  consoleClient:  
  consoleClientSecret: 
  consoleAdminIdentifier: 
  skipSSLValidation: false
# SCF values compatability 
env:
  DOMAIN:
  UAA_HOST: 
  UAA_PORT: 2793
  # UAA Zone (namespace cf ias deployed to when deployed to Kubernetes)
  UAA_ZONE: scf

  # SMTP Settings for Email Sending (User Invites)
  # If true, authenticate against the SMTP server using AUTH command.
  SMTP_AUTH: "false"

  # SMTP from address
  SMTP_FROM_ADDRESS: ~

  # SMTP server username
  SMTP_USER: ~

  # SMTP server password
  SMTP_PASSWORD: ~

  # SMTP server host address
  SMTP_HOST: ~

  # SMTP server port
  SMTP_PORT: "25"

kube:
  # Whether RBAC is enabled in the Kubernetes cluster
  auth: "rbac"
  external_console_https_port: 8443
  storage_class:
    persistent:
  organization: cap
  registry:
    hostname: registry.suse.com
    username:
    password:
    email: default
services:
  loadbalanced: false
metrics:
  enabled: false
EOF
helm install suse/console --name stratos-console --namespace stratos --values /tmp/stratos-values.yaml
rm /tmp/stratos-values.yaml
