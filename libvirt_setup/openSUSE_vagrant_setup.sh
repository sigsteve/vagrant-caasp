# Taken from: github.com/openSUSE/vagrant-ceph

set -ex

zypper in -y --allow-unsigned-rpm https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.rpm

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

