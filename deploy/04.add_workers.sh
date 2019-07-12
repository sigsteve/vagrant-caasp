#!/bin/bash
cd /vagrant/cluster/caasp4-cluster
source /vagrant/caasp_env.conf
source /vagrant/utils.sh
echo "Adding workers..."
set -x
for NUM in $(seq 1 $NWORKERS); do
    skuba node join --role worker --user sles --sudo --target caasp4-worker-${NUM} caasp4-worker-${NUM}
done
set +x
wait_for_masters_ready
wait_for_workers_ready
set -x
skuba cluster status
kubectl get nodes -o wide
set +x
