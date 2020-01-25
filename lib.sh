#!/bin/bash

# This reads in the config.yml file and
# Parses it into env vars
# minimal_nodes_master_memory
# minimal_nodes_master_cpus
# small_nodes_master_memory
# etc.
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Read the config.yml in
eval $(parse_yaml config.yml)

# Get the count of each node type from the model
num_masters="${CAASP_CONFIG_MODEL}_nodes_master_count"
NMASTERS=${!num_masters}
export NMASTERS
num_workers="${CAASP_CONFIG_MODEL}_nodes_worker_count"
NWORKERS=${!num_workers}
export NWORKERS
num_loadbal="${CAASP_CONFIG_MODEL}_nodes_loadbalancer_count"
NLOADBAL=${!num_loadbal}
export NLOADBAL
num_storage="${CAASP_CONFIG_MODEL}_nodes_storage_count"
NSTORAGE=${!num_storage}
export NSTORAGE

# write out caasp_env.conf so the /vagrant/deploy
# scripts have the correct node counts
cat > caasp_env.conf << EOF
NMASTERS=$NMASTERS
NWORKERS=$NWORKERS
NLOADBAL=$NLOADBAL
NSTORAGE=$NSTORAGE

# The config model chosen at deploy_caasp.sh time
MODEL=$CAASP_CONFIG_MODEL
SKUBA_VERBOSITY=${SKUBA_VERBOSITY}
EOF
