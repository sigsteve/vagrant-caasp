# Taken from: https://github.com/SUSE/sesdev#install-vagrant

$ sudo zypper ar https://download.opensuse.org/repositories/Virtualization:/vagrant/<repo> vagrant_repo
$ sudo zypper ref
$ sudo zypper -n install vagrant vagrant-libvirt
Where <repo> can be openSUSE_Leap_15.1 or openSUSE_Tumbleweed
