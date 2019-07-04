#!/bin/bash 
cd /vagrant/cluster/caasp4-cluster
echo "Bootstrapping cluster..."
set -x
skuba node bootstrap --user sles --sudo --target caasp4-master-1 caasp4-master-1

skuba cluster status
set +x
mkdir ~/.kube
ln -sf /vagrant/cluster/caasp4-cluster/admin.conf ~/.kube/config

set -x
kubectl get nodes -o wide
set +x
