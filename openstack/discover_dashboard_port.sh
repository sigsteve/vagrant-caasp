#!/bin/bash
echo "Kube Dashboard port = "
kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard -n kube-system
echo ""
