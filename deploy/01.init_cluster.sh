#!/bin/bash
. /vagrant/deploy/util-args.sh

if [ "$(hostname -s|grep -c master)" -ne 1 ]; then
    echo "This must be run on the master..."
    exit 1
fi

cd /vagrant/cluster
rm -fr caasp4-cluster 2>/dev/null
echo "Initializing cluster..."
set -x
skuba cluster init -v $VERBOSITY --control-plane caasp4-lb-1 caasp4-cluster
chmod g+rx caasp4-cluster
set +x
