#!/bin/bash
# Taken from: github.com/openSUSE/vagrant-ceph

set -ex

#check if rpmdev-vercmp is available, if not install rpmdevtools
type rpmdev-vercmp >/dev/null 2>&1 || { zypper install --no-confirm rpmdevtools; }

# install vagrant and it dependencies, devel files to build vagrant plugins later
# use new --allow-unsigned-rpm option if zypper supports it
rpmdev-vercmp zypper-1.14.4 $(rpm -qa zypper)
if [[ $? -eq 11 ]]; then
    zypper --no-gpg-checks in -y https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.rpm
else
    zypper in -y --allow-unsigned-rpm https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.rpm
fi

# workaround for https://github.com/hashicorp/vagrant/issues/10019
mv /opt/vagrant/embedded/lib/libreadline.so.7{,.disabled} | true
    
zypper in -y ruby-devel
zypper in -y gcc gcc-c++ make
zypper in -y qemu-kvm libvirt-daemon-qemu libvirt libvirt-devel

#need for vagrant-libvirt
gem install ffi
gem install unf_ext
gem install ruby-libvirt

systemctl enable libvirtd
systemctl start libvirtd

vagrant plugin install vagrant-libvirt

