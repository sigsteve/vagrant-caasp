#!/bin/bash
source caasp_env.conf

function printHelp {
cat << EOF
Usage ${0##*/} [options..]
-f, --full           attempt to bring the machines up and deploy the cluster
-i, --ignore-memory  Don't prompt when over allocating memory
-h,-?, --help        Show help
EOF
}

#initialize all the options
FULL_DEPLOYMENT=false
DO_MEMORY_CHECK=true
while :; do
    case $1 in
        -h|-\?|--help)
            printHelp
            exit
            ;;
        -f|--full)
            FULL_DEPLOYMENT=true
            ;;
        -i|--ignore-memory)
            DO_MEMORY_CHECK=false
            ;;
        --)                 #End of all options
            shift
            break
            ;;
        -?*)
            printf "'$1' is not a valid option\n" >&2
            exit 1
            ;;
        *)                 #Break out of case, no more options
            break
    esac
    shift
done

if [[  $DO_MEMORY_CHECK == true ]]; then
    # Check memory configuration with host
    MASTERMEM=$(sed -n '1,/caasp4-master-/d;/end/,$d;s/lv\.memory = "\([0-9]*\).*/\1/p' Vagrantfile)
    WORKERMEM=$(sed -n '1,/caasp4-worker-/d;/end/,$d;s/lv\.memory = "\([0-9]*\).*/\1/p' Vagrantfile)
    LBMEM=$(sed -n '1,/caasp4-lb-/d;/end/,$d;s/lv\.memory = "\([0-9]*\).*/\1/p' Vagrantfile)
    STORAGEMEM=$(sed -n '1,/caasp4-storage-/d;/end/,$d;s/lv\.memory = "\([0-9]*\).*/\1/p' Vagrantfile)
    MEMNEEDED="$(($MASTERMEM * $NMASTERS + $WORKERMEM * $NWORKERS + $LBMEM * $NLOADBAL + $STORAGEMEM * $NSTORAGE))"
    MEMHOST="$(free -m | awk 'NR==2{print $7}')"
    if [[ "$MEMNEEDED" -gt "$MEMHOST" ]]; then
        read -r -p "The configuration needs ${MEMNEEDED}MB but the host only has ${MEMHOST}MB available, do you want to continue [y/N] " response
        response=${response,,}
        if [[ ! "$response" =~ ^(yes|y)$ ]]; then
            exit 1
        fi
    fi
fi

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
