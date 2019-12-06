#!/bin/bash
. /vagrant/caasp_env.conf
. /vagrant/deploy/util-args.sh

cd /vagrant/cluster/caasp4-cluster
echo "Adding additional masters..."
set -x
for NUM in $(seq 2 $NMASTERS); do
    skuba node join -v $VERBOSITY --role master --user sles --sudo --target caasp4-master-${NUM} caasp4-master-${NUM}
done
skuba cluster status -v $VERBOSITY
kubectl get nodes -o wide
set +x
