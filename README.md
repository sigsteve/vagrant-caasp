# vagrant-caasp -- BETA
An automated deployment of SUSE CaaS Platform (Kubernetes) v4.1 for testing.

This project is a work in progress and will be cleaned up after some testing and feedback.
Feel free to open issues and/or submit PRs.

# What you get
* (1-2) Load balancers
* (1-3) Masters
* (1-5) Workers
* (1) Storage node setup with an NFS export for the nfs-client storage provisioner
* (1) Kubernetes Dashboard deployment
* (1) MetalLB instance
* (1) Optional Rook / Ceph / SES setup

# ASSUMPTIONS
* You're running openSUSE Tumbleweed or Leap 15+
* You have at least 8GB of RAM to spare
* You have the ability to run VMs with KVM
* You have an internet connection (images pull from internet, box comes from download.suse.de)
* DNS works on your system hosting the virtual machines (if getent hosts \`hostname -s\` hangs, you will encounter errors)
* You enjoy troubleshooting :P

# INSTALLATION (As root)
```sh
sysctl -w net.ipv6.conf.all.disable_ipv6=1 # rubygems.org has had issues pulling via IPv6
git clone https://github.com/sigsteve/vagrant-caasp
cd vagrant-caasp
# Install dependent packages and configure vagrant-libvirt
./libvirt_setup/openSUSE_vagrant_setup.sh
```

# NETWORK SETUP (As root)
```sh
# Make sure ip forwarding is enabled for the proper interfaces
# Fresh vagrant-libvirt setup
virsh net-create ./libvirt_setup/vagrant-libvirt.xml
# _OR_ if you already have the vagrant-libvirt network
./libvirt_setup/add_hosts_to_net.sh
# Update host firewall (if applicable)
./libvirt_setup/update_firewall.sh
```

# ADD BOX (As root)
```sh
# Find the latest box at http://download.suse.de/ibs/home:/sbecht:/vc-test:/SLE-15-SP1/images/
vagrant box add sle15sp1 \
    http://download.suse.de/ibs/home:/sbecht:/vc-test:/SLE-15-SP1/images/<box>
# _OR_
# wget/curl the box and 'vagrant box add sle15sp1 </path/to/box>'
```

# OPTIONAL -- running as a user other than root
```sh
# Become root (su), then
echo "someuser ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/someuser
visudo -c -f /etc/sudoers.d/someuser
# Add user to libvirt group
usermod --append --groups libvirt someuser
su - someuser
vagrant plugin install vagrant-libvirt
# ssh-keygen if you don't have one already
ssh-copy-id root@localhost
# Add any boxes (if you have boxes installed as other users, you'll need to add them here)
vagrant box add [boxname] /path/to/boxes
```

# USAGE
Examine the config.yml to view the model to choose for the size of each VM.
The config.yml configures the amount of RAM and CPUs for each type of vm as
well as the number of vms for each type:
master, workers, load balancers, storage

The current model list is
minimal, small, medium, large

The `deploy_caasp.sh` must be run as either `root` or `sles` user.

```sh
# Initial deployment
cd vagrant-caasp
./deploy_caasp.sh -m <model> < --full >
# --full will attempt to bring the machines up and deploy the cluster.
# Please adjust your memory settings in the config.yml for each machine type.
# Do not run vagrant up, unless you know what you're doing and want the result
Usage deploy_caasp.sh [options..]
-m, --model <model>   Which config.yml model to use for vm sizing
                      Default: "minimal"
-f, --full            attempt to bring the machines up and deploy the cluster
-i, --ignore-memory   Don't prompt when over allocating memory
-v, --verbose [uint8] Debug level to pass to skuba
-t, --test            Do a dry run, don't actually deploy the vms
-h,-?, --help         Show help
```

Once you have a CaaSP cluster provisioned you can start and stop that cluster by using the `cluster.sh` script
```sh
Usage cluster.sh [options..] [command]
-v, --verbose       Make the operation more talkative
-h,-?, --help       Show help and exit

start               start a previosly provisioned cluster
stop                stop a running cluster

dashboardInfo       get Dashboard IP, PORT and Token
monitoringInfo      get URLs and credentials for monitoring stack
```

# INSTALLING CAASP (one step at a time)
After running `deploy_caasp.sh -m <model>` without the --full option, do the following.
```sh
vagrant ssh caasp4-master-1
sudo su - sles
cd /vagrant/deploy
# source this
source ./00.prep_environment.sh
# skuba init
./01.init_cluster.sh
# skuba bootstrap (setup caasp4-master-1)
./02.bootstrap_cluster.sh
# add extra masters (if masters > 1)
./03.add_masters.sh
# add workers
./04.add_workers.sh
# setup helm
./05.setup_helm.sh
# wait for tiller to come up... Can take a few minutes.
# add NFS storage class (via helm)
./06.add_k8s_nfs-sc.sh
# add Kubernetes Dashboard
./07.add_dashboard.sh
# add MetalLB
./08.add_metallb.sh
```
# INSTALLING CAASP (all at once)
```sh
vagrant ssh caasp4-master-1
sudo su - sles
cd /vagrant/deploy
./99.run-all.sh
```
# Rook + SES / Ceph
```sh
# For rook, you must deploy with a model that has a tag with _rook.
# See config.yml large_rook for example.
# This will handle all setup and configuration for you.
# Currently the default storage class will remain NFS.
#
# To make SES your default storage class:
/vagrant/rook/switch_default_sc_to_ses.sh
# To see status:
/vagrant/rook/rook_status.sh
```
# OPENSTACK
(details to be documented)

# CAP
(details to be documented)

# EXAMPLES
* FULL DEPLOY
[![asciicast](https://asciinema.org/a/pBBBZUKQINb3CwhaVwiTk0Gvx.svg)](https://asciinema.org/a/pBBBZUKQINb3CwhaVwiTk0Gvx)

* INSTALL

* DESTROY
```sh
./destroy_caasp.sh
```

# NOTES


