#!/bin/bash
set -xe

source /vagrant/scripts/common.sh

: ${OSH_INFRA_PATH:="../openstack-helm-infra"}
#NOTE: Deploy command
helm upgrade --install nfs-provisioner ${OSH_INFRA_PATH}/nfs-provisioner \
    --namespace=nfs \
    --set storageclass.name=general \
    ${OSH_EXTRA_HELM_ARGS_NFS_PROVISIONER}

#NOTE: Wait for deploy
$OSH_INFRA_PATH/tools/deployment/common/wait-for-pods.sh nfs

#NOTE: Display info
helm status nfs-provisioner
