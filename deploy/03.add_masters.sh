#!/bin/bash
. /vagrant/caasp_env.conf

cd /vagrant/cluster/caasp4-cluster
echo "Adding additional masters..."
set -x
skuba node join --role master --user sles --sudo --target caasp4-master-2 caasp4-master-2
skuba node join --role master --user sles --sudo --target caasp4-master-3 caasp4-master-3

skuba cluster status
kubectl get nodes -o wide
set +x
