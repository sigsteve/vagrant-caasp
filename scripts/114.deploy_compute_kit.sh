#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/160-compute-kit.sh
