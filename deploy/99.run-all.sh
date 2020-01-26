#!/bin/bash
eval $(ssh-agent -s)
ssh-add /vagrant/cluster/caasp4-id
. /vagrant/caasp_env.conf
cd /vagrant/deploy

./01.init_cluster.sh 
./02.bootstrap_cluster.sh 
./03.add_masters.sh 
./04.add_workers.sh 
./05.setup_helm.sh
printf "Waiting for tiller to become available. This can take a couple of minutes."
while [[ $(kubectl --namespace kube-system get pods | egrep -c "tiller-deploy-.* 1/1     Running") -eq 0 ]]
do
    printf "."
    sleep 5
done
printf "\n"
./06.add_k8s_nfs-sc.sh
./07.add_dashboard.sh
./08.add_metallb.sh
if [[ "${MODEL}" =~ "_rook" ]]; then
    echo "Setting up rook..."
    /vagrant/rook/rook_setup.sh
fi
./98.status.sh
ST=$(kubectl -n kube-system get serviceaccounts admin-user -o jsonpath="{.secrets[0].name}")
SECRET=$(kubectl -n kube-system get secret ${ST} -o jsonpath="{.data.token}"|base64 -d)
#NODE_PORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard -n kube-system)
#NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" -n kube-system)
export NODE_PORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard -n kubernetes-dashboard)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" -n kubernetes-dashboard)

echo "Access your dashboard at: https://$NODE_IP:$NODE_PORT/"
echo "Your login token is: ${SECRET}"
echo
echo "Happy CaaSPing!"
echo
