#!/bin/bash -x
 vagrant destroy -f
 vagrant box remove sle15sp1
 sudo rm /var/lib/libvirt/images/sle15sp1_vagrant_box_image_0.img
 virsh pool-refresh default
