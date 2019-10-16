cd /usr/share/k8s-yaml/rook/ceph
kubectl apply -f common.yaml -f operator.yaml
kubectl apply -f cluster.yaml
kubectl apply -f toolbox.yaml

kubectl apply -f /vagrant/rook/sc.yaml
