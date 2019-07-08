#!/bin/bash
. /vagrant/caasp_env.conf

cd /vagrant/cluster/caasp4-cluster
echo "Adding additional masters..."
set -x
for NUM in $(seq 2 $NMASTERS); do
    skuba node join --role master --user sles --sudo --target caasp4-master-${NUM} caasp4-master-${NUM}
done
skuba cluster status
kubectl get nodes -o wide
set +x
