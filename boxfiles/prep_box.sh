#!/bin/bash 

useradd -m sles
echo "sles ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/sles
mkdir -p ~sles/.ssh
cp /vagrant/cluster/caasp4-id.pub ~sles/.ssh/authorized_keys
chmod 700 ~sles/.ssh
chmod 600 ~sles/.ssh/authorized_keys
chown -R sles ~sles/.ssh
# rm -f /etc/zypp/repos.d/*
#sed -i 's/DHCLIENT_HOSTNAME_OPTION="AUTO"/DHCLIENT_HOSTNAME_OPTION=""/g' /etc/sysconfig/network/dhcp
myip=$(ip a sh eth0|sed -n 's;.*inet \(.*\)/.*;\1;p')
echo ${myip} $(hostname -f) $(hostname -s)

if [ ! -d /vagrant/cluster ]; then
    mkdir /vagrant/cluster
    chown -R sles:users /vagrant/cluster
fi

if [ ! -f /vagrant/cluster/caasp4-id ]; then
    ssh-keygen -t rsa -f /vagrant/cluster/caasp4-id -P ''
    chown sles:users /vagrant/cluster/caasp4-id
    chown sles:users /vagrant/cluster/caasp4-id.pub
fi
