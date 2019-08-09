#!/bin/bash
vagrant destroy -f
# cleanup some files...
rm -fr ./cluster 2>/dev/null
