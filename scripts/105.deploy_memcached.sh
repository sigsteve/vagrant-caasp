#!/bin/bash
set -xe

source ~/scripts/common.sh

#NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
: ${OSH_EXTRA_HELM_ARGS_MEMCACHED:="$($OSH_INFRA_PATH/tools/deployment/common/get-values-overrides.sh memcached)"}

#NOTE: Lint and package chart
make -C ${HELM_CHART_ROOT_PATH} memcached

tee /tmp/memcached.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  memcached:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: keystone
        - podSelector:
            matchLabels:
              application: heat
        - podSelector:
            matchLabels:
              application: glance
        - podSelector:
            matchLabels:
              application: cinder
        - podSelector:
            matchLabels:
              application: congress
        - podSelector:
            matchLabels:
              application: barbican
        - podSelector:
            matchLabels:
              application: ceilometer
        - podSelector:
            matchLabels:
              application: horizon
        - podSelector:
            matchLabels:
              application: ironic
        - podSelector:
            matchLabels:
              application: magnum
        - podSelector:
            matchLabels:
              application: mistral
        - podSelector:
            matchLabels:
              application: nova
        - podSelector:
            matchLabels:
              application: neutron
        - podSelector:
            matchLabels:
              application: senlin
        ports:
        - protocol: TCP
          port: 11211
EOF

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install memcached ${HELM_CHART_ROOT_PATH}/memcached \
    --namespace=openstack \
    --values=/tmp/memcached.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_MEMCACHED}

#NOTE: Wait for deploy
$OSH_INFRA_PATH/tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status memcached
