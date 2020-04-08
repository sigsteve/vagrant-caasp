#!/bin/bash
kubectl apply -f /vagrant/rook/filesystem.yaml
kubectl apply -f /vagrant/rook/sc-cephfs.yaml

