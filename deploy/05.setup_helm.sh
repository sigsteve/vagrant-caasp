#!/bin/bash
echo "Setting up helm..."
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#helm init
#kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account=tiller --stable-repo-url https://charts.helm.sh/stable --wait
helm repo add suse https://kubernetes-charts.suse.com
