#!/bin/bash
echo "Installing Kubernetes Dashboard..."
helm install stable/kubernetes-dashboard --namespace kube-system --name kubernetes-dashboard --set service.type=NodePort

cat > dashboard-admin.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
EOF

kubectl apply -f dashboard-admin.yaml

cat > admin-user-crb.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kube-system
EOF

kubectl apply -f admin-user-crb.yaml

helm status kubernetes-dashboard

ST=$(kubectl -n kube-system get serviceaccounts admin-user -o jsonpath="{.secrets[0].name}")
SECRET=$(kubectl -n kube-system get secret ${ST} -o jsonpath="{.data.token}"|base64 -d)
export NODE_PORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard -n kube-system)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" -n kube-system)
echo "Access your dashboard at: https://$NODE_IP:$NODE_PORT/"
echo "Your login token is: ${SECRET}"


