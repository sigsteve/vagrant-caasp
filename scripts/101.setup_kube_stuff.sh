#!/bin/bash


# This script does some setup of kube shit before trying
# to deploy any helm charts.
source /vagrant/caasp_env.conf

set -x
for NUM in $(seq 1 $NWORKERS); do
  kubectl label nodes caasp4-worker-${NUM} openstack-control-plane=enabled
  kubectl label nodes caasp4-worker-${NUM} openstack-compute-node=enabled
done

kubectl label nodes caasp4-worker-1 openvswitch=enabled
kubectl label nodes caasp4-worker-1 openstack-helm-node-class=primary

tee /tmp/suse-sa-clusterrolebindings.yml <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: PrivilegedRoleBinding
roleRef:
  kind: ClusterRole
  name: suse:caasp:psp:privileged
  apiGroup: rbac.authorization.k8s.io
subjects:
# Authorize specific service accounts:
- kind: ServiceAccount
  name: cinder-backup
  namespace: openstack
- kind: ServiceAccount
  name: nova-novncproxy
  namespace: openstack
- kind: ServiceAccount
  name: openvswitch-vswitchd
  namespace: openstack
- kind: ServiceAccount
  name: libvirt 
  namespace: openstack
- kind: ServiceAccount
  name: neutron-dhcp-agent
  namespace: openstack
- kind: ServiceAccount
  name: neutron-l3-agent
  namespace: openstack
- kind: ServiceAccount
  name: neutron-metadata-agent
  namespace: openstack
- kind: ServiceAccount
  name: nova-compute
  namespace: openstack
- kind: ServiceAccount
  name: neutron-ovs-agent
  namespace: openstack
- kind: ServiceAccount
  name: openvswitch-db
  namespace: openstack
- kind: ServiceAccount
  name: ingress-kube-system-ingress
  namespace: kube-system
- kind: ServiceAccount
  name: nfs-provisioner-nfs-provisioner
  namespace: nfs
EOF
kubectl apply -f /tmp/suse-sa-clusterrolebindings.yml
