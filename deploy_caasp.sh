#!/bin/bash


function printHelp {
cat << EOF
Usage ${0##*/} [options..]
-m, --model <model>  Which config.yml model to use for vm sizing
                     Default: "minimal"
-f, --full           attempt to bring the machines up and deploy the cluster
-i, --ignore-memory  Don't prompt when over allocating memory
-t, --test           Do a dry run, don't actually deploy the vms.
-h,-?, --help        Show help
EOF
}


# Get all models in the file
VALID_MODELS=`egrep '^[a-zA-Z]' config.yml |tr ':' ' '|tr -d '\r\n' `

function validate_model {
  local result=0
  if [[ " $VALID_MODELS " =~ .*\ $1\ .* ]]; then
    result=1
  fi
  echo "$result"
}

function invalid_model {
    echo "Invalid model option, must be one of '$VALID_MODELS'."
    echo "Update config.yml if needed."
    exit 1
}

CAASP_CONFIG_MODEL="minimal"
DO_MEMORY_CHECK=true
FULL_DEPLOYMENT=false
DO_DRY_RUN=false
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h|-\?|--help)
      printHelp
      exit
      ;;
    -m|--model)
      CAASP_CONFIG_MODEL=$2
      shift 2
      ;;
    -f|--full)
      FULL_DEPLOYMENT=true
      shift
      ;;
    -i|--ignore-memory)
      DO_MEMORY_CHECK=false
      shift
      ;;
    -t|--test)
      DO_DRY_RUN=true
      shift
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

res=$(validate_model $CAASP_CONFIG_MODEL)
if [ "$res" -eq "0" ]; then
    invalid_model
fi

# This is so Vagrantfile can read the
# selected model
export CAASP_CONFIG_MODEL

# read in the config.yml and write out the caasp_env.conf
source lib.sh

# Collect System Requirements
master_ram="${CAASP_CONFIG_MODEL}_nodes_master_memory"
master_cpus="${CAASP_CONFIG_MODEL}_nodes_master_cpus"
MASTERMEM=${!master_ram}
worker_ram="${CAASP_CONFIG_MODEL}_nodes_worker_memory"
worker_cpus="${CAASP_CONFIG_MODEL}_nodes_worker_cpus"
WORKERMEM=${!worker_ram}
lb_ram="${CAASP_CONFIG_MODEL}_nodes_loadbalancer_memory"
lb_cpus="${CAASP_CONFIG_MODEL}_nodes_loadbalancer_cpus"
LBMEM=${!lb_ram}
storage_ram="${CAASP_CONFIG_MODEL}_nodes_storage_memory"
storage_cpus="${CAASP_CONFIG_MODEL}_nodes_storage_cpus"
STORAGEMEM=${!storage_ram}
MEMNEEDED="$(($MASTERMEM * $NMASTERS + $WORKERMEM * $NWORKERS + $LBMEM * $NLOADBAL + $STORAGEMEM * $NSTORAGE))"
MEMHOST="$(free -m | awk 'NR==2{print $7}')"

if [[  $DO_MEMORY_CHECK == true ]]; then
    # Check memory configuration with host
    if [[ "$MEMNEEDED" -gt "$MEMHOST" ]]; then
        read -r -p "The configuration needs ${MEMNEEDED}MB but the host only has ${MEMHOST}MB available, do you want to continue [y/N] " response
        response=${response,,}
        if [[ ! "$response" =~ ^(yes|y)$ ]]; then
            exit 1
        fi
    fi
fi

echo "Deploy CAASP with the CAASP_CONFIG_MODEL=$CAASP_CONFIG_MODEL"
echo "  Masters=$NMASTERS         CPUS=${!master_cpus} MEM=$MASTERMEM"
echo "  Workers=$NWORKERS         CPUS=${!worker_cpus} MEM=$WORKERMEM"
echo "  Load Balancers=$NLOADBAL  CPUS=${!lb_cpus} MEM=$LBMEM"
echo "  Storage Nodes=$NSTORAGE   CPUS=${!storage_cpus} MEM=$STORAGEMEM"

total_cpus="$((${!master_cpus}*$NMASTERS + ${!worker_cpus}*$NWORKERS + ${!lb_cpus}*$NLOADBAL + ${!storage_cpus}*$NSTORAGE))"
total_mem="$(($MASTERMEM*$NMASTERS + $WORKERMEM*$NWORKERS + $LBMEM*$NLOADBAL + $STORAGEMEM*$NSTORAGE))"

echo "TOTALS CPU=$total_cpus MEM=$total_mem"
echo ""

if [ "$FULL_DEPLOYMENT" == true ]; then
    echo "Do full deployment after VMs are up."
else
    echo "Not running deployment scripts after VMs are up."
fi

if [[ $DO_DRY_RUN == true ]]; then
    echo "Dry run complete"
    exit
fi

#
# Now do the work of standing up the vms
#

echo "Deploying $NMASTERS masters"
for m in $(seq ${NMASTERS})
do
    vagrant up caasp4-master-${m}
done

echo "Deploying $NWORKERS workers"
for w in $(seq ${NWORKERS})
do
    vagrant up caasp4-worker-${w}
done

echo "Deploying $NLOADBAL load balancers"
for l in $(seq ${NLOADBAL})
do
    vagrant up caasp4-lb-${l}
done

echo "Deploying $NSTORAGE storage nodes"
for s in $(seq ${NSTORAGE})
do
    vagrant up caasp4-storage-${s}
done

if [[ $FULL_DEPLOYMENT == true ]]; then
    vagrant ssh caasp4-master-1 -c 'sudo su - sles -c /vagrant/deploy/99.run-all.sh'
fi

echo "Happy CaaSPing!"
echo "vagrant ssh caasp4-master-1"
echo "sudo su - sles"
echo "See scripts in the /vagrant/deploy directory for deployment guide steps"
echo "...or run $0 --full to have your cluster auto-deployed"
