#!/bin/bash
kubectl get po -A
kubectl get no
cd /vagrant/cluster/caasp4-cluster
skuba cluster status
