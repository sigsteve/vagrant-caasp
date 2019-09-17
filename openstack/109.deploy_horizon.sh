#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/100-horizon.sh
