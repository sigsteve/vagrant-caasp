#!/bin/bash -x
if [ ! -f cluster/caasp4-id ]; then
    ssh-keygen -t rsa -f cluster/caasp4-id -P ''
fi

