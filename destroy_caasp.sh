#!/bin/bash
vagrant destroy -f
# cleanup some files...
sudo rm -fr ./cluster 2>/dev/null
