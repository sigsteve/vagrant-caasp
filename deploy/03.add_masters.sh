#!/bin/bash
. /vagrant/caasp_env.conf

cd /vagrant/cluster/caasp4-cluster

SKUBA_VERBOSITY=$(sed -n 's/^SKUBA_VERBOSITY=\([0-99]\).*/\1/p' /vagrant/caasp_env.conf|tail -1)
SKUBA_VERBOSITY=${SKUBA_VERBOSITY:-1}

echo "Adding additional masters..."
set -x
for NUM in $(seq 2 $NMASTERS); do
    skuba -v ${SKUBA_VERBOSITY} node join --role master --user sles --sudo --target caasp4-master-${NUM} caasp4-master-${NUM}
done
skuba -v ${SKUBA_VERBOSITY} cluster status
kubectl get nodes -o wide
set +x
