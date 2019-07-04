#!/bin/bash

mkdir /nfs
echo '/nfs     *.suselab.com(rw,no_root_squash)' >/etc/exports
systemctl enable --now nfs-server
exportfs -a
