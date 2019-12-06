#!/bin/bash 
. /vagrant/deploy/util-args.sh

cd /vagrant/cluster/caasp4-cluster
echo "Bootstrapping cluster..."
set -x
skuba node bootstrap --user sles -v $VERBOSITY --sudo --target caasp4-master-1 caasp4-master-1

skuba cluster status -v $VERBOSITY
set +x
mkdir ~/.kube
ln -sf /vagrant/cluster/caasp4-cluster/admin.conf ~/.kube/config
chmod g+r /vagrant/cluster/caasp4-cluster/admin.conf

set -x
kubectl get nodes -o wide
set +x
