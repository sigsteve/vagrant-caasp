#!/bin/bash
. caasp_env.conf
export CAASP_CONFIG_MODEL=${MODEL}
vagrant destroy -f
# cleanup some files...
sudo rm -fr ./cluster 2>/dev/null
