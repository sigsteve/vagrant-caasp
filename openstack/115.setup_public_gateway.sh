#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/170-setup-gateway.sh
