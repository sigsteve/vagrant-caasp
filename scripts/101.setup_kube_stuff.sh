#!/bin/bash


# This script does some setup of kube shit before trying
# to deploy any helm charts.
source /vagrant/caasp_env.conf

set -x
for NUM in $(seq 1 $NWORKERS); do
  kubectl label nodes caasp4-worker-${NUM} openstack-control-plane=enabled
  kubectl label nodes caasp4-worker-${NUM} openstack-compute-node=enabled
done
