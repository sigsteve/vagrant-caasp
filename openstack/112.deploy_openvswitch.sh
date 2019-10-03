#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/140-openvswitch.sh
