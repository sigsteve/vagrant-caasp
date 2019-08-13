#!/bin/bash
MLBCONFIG=/tmp/metallb.yaml

echo "Setting up MetalLB..."

kubectl create namespace metallb-system

cat > ${MLBCONFIG} <<EOF
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - 192.168.121.240-192.168.121.250
EOF

#kubectl apply -f ${MLBCONFIG}
helm install --namespace metallb-system --name metallb stable/metallb -f ${MLBCONFIG}
rm ${MLBCONFIG}
