#!/bin/bash

# This script patches the 030-ingress.sh standup script
# so that we have a consistent ingress VIP so we can have
# our openstack services on
cd ~sles/openstack-helm

git apply /vagrant/openstack/patch-030-ingress.patch
