#!/bin/bash 

useradd -m sles
usermod -v 10000000-20000000 -w 10000000-20000000 sles

echo "sles ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/sles

mkdir -p ~sles/.ssh
mkdir -p ~root/.ssh

if [ ! -d /vagrant/cluster ]; then
    mkdir /vagrant/cluster
    chown -R sles:users /vagrant/cluster
fi

if [ ! -f /vagrant/cluster/caasp4-id ]; then
    ssh-keygen -t rsa -f /vagrant/cluster/caasp4-id -P ''
    chown sles /vagrant/cluster/caasp4-id
    chown sles /vagrant/cluster/caasp4-id.pub
fi

cat /vagrant/cluster/caasp4-id.pub >> ~sles/.ssh/authorized_keys
cat /vagrant/cluster/caasp4-id.pub >> ~root/.ssh/authorized_keys

chmod 700 ~sles/.ssh
chmod 600 ~sles/.ssh/authorized_keys
chmod 700 ~root/.ssh
chmod 600 ~root/.ssh/authorized_keys
chown -R sles ~sles/.ssh

cp /vagrant/boxfiles/motd /etc/motd

# rm -f /etc/zypp/repos.d/*
#sed -i 's/DHCLIENT_HOSTNAME_OPTION="AUTO"/DHCLIENT_HOSTNAME_OPTION=""/g' /etc/sysconfig/network/dhcp
myip=$(ip a sh eth0|sed -n 's;.*inet \(.*\)/.*;\1;p')
echo ${myip} $(hostname -f) $(hostname -s)

