#!/bin/bash
cd /vagrant/cluster/caasp4-cluster
source /vagrant/caasp_env.conf
source /vagrant/utils.sh

SKUBA_VERBOSITY=$(sed -n 's/^SKUBA_VERBOSITY=\([0-99]\).*/\1/p' /vagrant/caasp_env.conf|tail -1)
SKUBA_VERBOSITY=${SKUBA_VERBOSITY:-1}

echo "Adding workers..."
set -x
for NUM in $(seq 1 $NWORKERS); do
    skuba -v ${SKUBA_VERBOSITY} node join --role worker --user sles --sudo --target caasp4-worker-${NUM} caasp4-worker-${NUM}
done
set +x
wait_for_masters_ready
wait_for_workers_ready
set -x
skuba -v ${SKUBA_VERBOSITY} cluster status
kubectl get nodes -o wide
set +x
