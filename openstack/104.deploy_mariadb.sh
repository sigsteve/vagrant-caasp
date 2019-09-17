#!/bin/bash
set -xe

cd ~sles/openstack-helm

./tools/deployment/developer/nfs/050-mariadb.sh
