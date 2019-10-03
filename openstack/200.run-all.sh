#!/bin/bash
STEPS=16
STEP=1

function showstep {
    echo "Step $STEP of $STEPS"
    STEP=$STEP+1
}


showstep
sudo ./000.zypper_repos.sh
showstep
./001.install_packages.sh
showstep
./002.setup_hosts.sh

showstep
sudo ./050.install_helm_service.sh
showstep
sudo ./051.setup_openstack_client.sh
showstep
./052.clone_upstream_helm_charts.sh
showstep
./053.patch-03-ingress.sh


showstep
./101.setup_kube_stuff.sh
showstep
./102.deploy_ingress.sh
showstep
./103.deploy_nfs.sh
showstep
./104.deploy_mariadb.sh
showstep
./105.deploy_rabbitMQ.sh
showstep
./106.deploy_memcached.sh
showstep
./107.deploy_keystone.sh
showstep
./108.deploy_heat.sh
showstep
./109.deploy_horizon.sh
showstep
./110.deploy_glance.sh
