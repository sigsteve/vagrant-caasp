# Taken from: github.com/openSUSE/vagrant-ceph

set -ex

# install vagrant and it dependencies, devel files to build vagrant plugins later
# use new --allow-unsigned-rpm option if zypper supports it
zypper_version=($(zypper -V))
if [[ ${zypper_version[1]} < '1.14.4' ]]
then
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

