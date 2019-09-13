#!/bin/bash
set -xe

cd ~sles
if [ ! -d ~sles/openstack-helm-infra ]; then
  git clone https://opendev.org/openstack/openstack-helm-infra.git
fi
cd openstack-helm-infra
make all

if [ ! -d ~sles/openstack-helm ]; then
  git clone https://opendev.org/openstack/openstack-helm.git
fi
cd ../openstack-helm
make all
