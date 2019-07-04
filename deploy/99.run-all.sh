#!/bin/bash
eval $(ssh-agent -s)
ssh-add /vagrant/cluster/caasp4-id
cd /vagrant/deploy

./01.init_cluster.sh 
./02.bootstrap_cluster.sh 
./03.add_masters.sh 
./04.add_workers.sh 
./05.setup_helm.sh
echo "Waiting for tiller to become available. This can take a couple of minutes..."
sleep 120
./06.add_k8s_nfs-sc.sh
./98.status.sh
echo
echo "Happy CaaSPing!"
echo
