#!/bin/bash

sudo zypper in -y wget make python3-pip jq bc

sudo pip install -U pip
sudo pip install "cmd2<=0.8.7"
sudo pip install python-openstackclient python-heatclient --ignore-installed
