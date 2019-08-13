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
./07.add_dashboard.sh
./08.add_metallb.sh
./98.status.sh
ST=$(kubectl -n kube-system get serviceaccounts admin-user -o jsonpath="{.secrets[0].name}")
SECRET=$(kubectl -n kube-system get secret ${ST} -o jsonpath="{.data.token}"|base64 -d)
NODE_PORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard -n kube-system)
NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" -n kube-system)
echo "Access your dashboard at: https://$NODE_IP:$NODE_PORT/"
echo "Your login token is: ${SECRET}"
echo
echo "Happy CaaSPing!"
echo
