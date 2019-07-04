#!/bin/bash 
cp /vagrant/boxfiles/nginx.conf /etc/nginx/nginx.conf
systemctl enable --now nginx
