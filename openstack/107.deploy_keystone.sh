#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/080-keystone.sh

