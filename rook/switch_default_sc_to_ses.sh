#!/bin/bash
echo "Changing default storage class to SES..."

echo "Current:"
kubectl get sc

# remove current default
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
# set new default to SES
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "New:"
kubectl get sc
