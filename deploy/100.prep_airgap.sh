#!/bin/bash
# Backup existing cri-o registries
cp /etc/containers/registries.conf /etc/containers/registries.conf.old
# Replace /etc/containers/registries.conf with customized one
cp /vagrant/air-gap.d/air-gapped-registries.conf /etc/containers/registries.conf
# Test for and append custom etc/hosts
if [[ -f "/vagrant/air-gap.d/add2hosts.in" ]]; then
    cat /vagrant/air-gap.d/add2hosts.in >> /etc/hosts
    echo "Modified /etc/hosts..."
fi
# Test for and integrate ca-cert if present
if [[ -f "/vagrant/air-gap.d/registry-ca.crt" ]]; then
    cp /vagrant/air-gap.d/registry-ca.crt /etc/pki/trust/anchors/
    update-ca-certificates
fi
# Restart cri-o with air-gap modifications in place
systemctl restart crio
    
