#!/bin/bash

# this script adds the required entries to the /etc/hosts file


tee -a /etc/hosts <<EOF
192.168.121.169    keystone    keystone.openstack.svc.cluster.local
192.168.121.169    glance      glance.openstack.svc.cluster.local
192.168.121.169    cinder      cinder.openstack.svc.cluster.local
192.168.121.169    nova        nova.openstack.svc.cluster.local
192.168.121.169    neutron     neutron.openstack.svc.cluster.local
192.168.121.169    horizon     horizon.openstack.svc.cluster.local
192.168.121.169    heat        heat.openstack.svc.cluster.local
EOF
