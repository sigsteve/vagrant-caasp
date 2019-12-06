#!/bin/bash
. /vagrant/deploy/util-args.sh
kubectl get po -A
kubectl get no
cd /vagrant/cluster/caasp4-cluster
skuba cluster status -v $VERBOSITY
