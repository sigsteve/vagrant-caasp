#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/120-glance.sh
