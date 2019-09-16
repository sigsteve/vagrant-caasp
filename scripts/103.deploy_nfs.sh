#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/040-nfs-provisioner.sh
