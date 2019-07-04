#!/bin/bash 
echo "Adding NFS storage class..."
helm install --name=nfs-client --set nfs.server=192.168.121.140 --set nfs.path=/nfs stable/nfs-client-provisioner
