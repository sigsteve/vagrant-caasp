#!/bin/bash -x
 vagrant destroy -f
 vagrant box remove vagrant-caasp
 sudo rm /var/lib/libvirt/images/vagrant-caasp_vagrant_box_image_0.img
 virsh pool-refresh default
