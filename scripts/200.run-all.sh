#!/bin/bash
STEPS=14

echo "Step 1 of $STEPS"
sudo ./000.zypper_repos.sh
echo "Step 2 of $STEPS"
./001.install_packages.sh

echo "Step 3 of $STEPS"
sudo ./050.install_helm_service.sh
echo "Step 4 of $STEPS"
sudo ./051.setup_openstack_client.sh

echo "Step 5 of $STEPS"
./052.clone_upstream_helm_charts.sh

echo "Step 6 of $STEPS"
./101.setup_kube_stuff.sh

echo "Step 7 of $STEPS"
./102.deploy_ingress.sh

echo "Step 8 of $STEPS"
./103.deploy_nfs.sh

echo "Step 8 of $STEPS"
./104.deploy_mariadb.sh

echo "Step 9 of $STEPS"
./105.deploy_rabbitMQ.sh

echo "Step 10 of $STEPS"
./106.deploy_memcached.sh

echo "Step 11 of $STEPS"
./107.deploy_keystone.sh

echo "Step 12 of $STEPS"
./108.deploy_heat.sh

echo "Step 13 of $STEPS"
./109.deploy_horizon.sh

echo "Step 14 of $STEPS"
./110.deploy_glance.sh
