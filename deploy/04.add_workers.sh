#!/bin/bash
cd /vagrant/cluster/caasp4-cluster
source /vagrant/caasp_env.conf
echo "Adding workers..."
set -x
for NUM in $(seq 1 $NWORKERS); do
    skuba node join --role worker --user sles --sudo --target caasp4-worker-${NUM} caasp4-worker-${NUM}
done

skuba cluster status
kubectl get nodes -o wide
set +x
