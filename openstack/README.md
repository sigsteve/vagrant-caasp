# Bootstrap a running kubernetes with OpenStack

This directory contains some scripts in order, to run on 
a caasp4-worker-1 node.   These scripts do the work
as described in the upstream openstack helm tutorial
for setting up kubernetes to deploy helm charts.  

The scripts pull down openstack-helm-infra and openstack-helm,
build all the charts and uses them to deploy some OpenStack
services.

# Requirements
It's assumed that you have either deployed the caasp4 kube with
deploy_caasp.sh --full or have run all of the scripts manually in
/vagrant/deploy.

# Services

The following are services that have been verified to work.
* mariadb
* memcached
* keystone
* heat
* horizon
* glance


# Scripts

You can either run the scripts manually or by running
the 200.run-all.sh script.  If you run the scripts manually,
some of them require sudo and others don't.  You'll have to look
inside them to determine which is which.

The 200.run-all.sh script will run all the scripts up through
and including the deploy_glance.sh script.   I haven't been able
to get the helm charts after glance to deploy correctly.

# kubernetes dashboard
You can run the discover_dashboard_port.sh script to find out what port
the Kubernetes dashboard is running on.  This port seems to change every 
time you deploy kube. The dashboard will be on http://192.168.121.120:<PORT>

To login cat the ~/.kube/config file and use the token at the bottom of the
file as the auth token.
