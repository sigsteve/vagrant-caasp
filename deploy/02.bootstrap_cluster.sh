#!/bin/bash 
cd /vagrant/cluster/caasp4-cluster

SKUBA_VERBOSITY=$(sed -n 's/^SKUBA_VERBOSITY=\([0-99]\).*/\1/p' /vagrant/caasp_env.conf|tail -1)
SKUBA_VERBOSITY=${SKUBA_VERBOSITY:-1}

echo "Bootstrapping cluster..."
set -x
skuba -v ${SKUBA_VERBOSITY} node bootstrap --user sles --sudo --target caasp4-master-1 caasp4-master-1

skuba -v ${SKUBA_VERBOSITY} cluster status
set +x
mkdir ~/.kube
ln -sf /vagrant/cluster/caasp4-cluster/admin.conf ~/.kube/config
chmod g+r /vagrant/cluster/caasp4-cluster/admin.conf

set -x
kubectl get nodes -o wide
set +x
