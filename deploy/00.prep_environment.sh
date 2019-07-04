#!/bin/bash -x
eval $(ssh-agent -s)
ssh-add /vagrant/cluster/caasp4-id
# XXX: nice error checking


