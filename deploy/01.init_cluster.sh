#!/bin/bash 
if [ "$(hostname -s|grep -c master)" -ne 1 ]; then
    echo "This must be run on the master..."
    exit 1
fi

SKUBA_VERBOSITY=$(sed -n 's/^SKUBA_VERBOSITY=\([0-99]\).*/\1/p' /vagrant/caasp_env.conf|tail -1)
SKUBA_VERBOSITY=${SKUBA_VERBOSITY:-1}

cd /vagrant/cluster
rm -fr caasp4-cluster 2>/dev/null
echo "Initializing cluster..."
set -x
skuba -v ${SKUBA_VERBOSITY} cluster init --control-plane caasp4-lb-1 caasp4-cluster
chmod g+rx caasp4-cluster
set +x
