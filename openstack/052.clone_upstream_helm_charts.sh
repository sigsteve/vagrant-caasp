#!/bin/bash
set -xe

cd ~sles
if [ ! -d ~sles/openstack-helm-infra ]; then
  git clone https://opendev.org/openstack/openstack-helm-infra.git
fi
cd ~sles/openstack-helm-infra
make all

cd ~sles
if [ ! -d ~sles/openstack-helm ]; then
  git clone https://opendev.org/openstack/openstack-helm.git
fi
cd ~sles/openstack-helm
make all
