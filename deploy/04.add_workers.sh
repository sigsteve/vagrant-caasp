#!/bin/bash
cd /vagrant/cluster/caasp4-cluster
echo "Adding workers..."
set -x
skuba node join --role worker --user sles --sudo --target caasp4-worker-1 caasp4-worker-1
skuba node join --role worker --user sles --sudo --target caasp4-worker-2 caasp4-worker-2
skuba node join --role worker --user sles --sudo --target caasp4-worker-3 caasp4-worker-3
skuba node join --role worker --user sles --sudo --target caasp4-worker-4 caasp4-worker-4
skuba node join --role worker --user sles --sudo --target caasp4-worker-5 caasp4-worker-5

skuba cluster status
kubectl get nodes -o wide
set +x
