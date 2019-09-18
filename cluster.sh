#!/bin/bash
source caasp_env.conf

function printHelp {
cat << EOF
Usage ${0##*/} [options..] [command]
-v, --verbose       Make the operation more talkative
-h,-?, --help       Show help and exit

start               start a previosly provisioned cluster
stop                stop a running cluster

dashboardInfo       get Dashboard IP, PORT and Token
monitoringInfo      get URLs and credentials for monitoring stack
EOF
}

#initialize all the options
VERBOSE=/bin/false
while :; do
    case $1 in
        -h|-\?|--help)
            printHelp
            exit
            ;;
        -v|--verbose)
            VERBOSE=/bin/true
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

function start_cluster {
    $VERBOSE && set -x
    # start loadbalancers
    printf "Starting loadbalancers:\n"
    for NUM in $(seq 1 $NLOADBAL); do
        vagrant reload caasp4-lb-${NUM}
    done
    printf "\n"

    # Starting storage
    printf "Starting storage:\n"
    for NUM in $(seq 1 $NSTORAGE); do
        vagrant reload caasp4-storage-${NUM}
    done
    printf "\n"

    printf "Starting master nodes\n"
    for NUM in $(seq 1 $NMASTERS); do
        vagrant reload caasp4-master-${NUM}
    done

    #Waiting for masters to become ready
    vagrant ssh caasp4-master-1 -c 'sudo -H -u sles bash -c "source /vagrant/utils.sh; wait_for_masters_ready"'

    printf "Starting worker nodes\n"
    for NUM in $(seq 1 $NWORKERS); do
        vagrant reload caasp4-worker-${NUM}
    done

    # Waiting for workers to become ready
    vagrant ssh caasp4-master-1 -c 'sudo -H -u sles bash -c "source /vagrant/utils.sh; wait_for_workers_ready"'

    printf "Starting scheduling on nodes.\n"
    vagrant ssh caasp4-master-1 -c 'sudo -H -u sles kubectl get nodes -o name | \
        sudo -H -u sles xargs -I{} kubectl uncordon {}'

    printf "Cluster is up and running.....\n"
    $VERBOSE && set +x

}

function stop_cluster {
    $VERBOSE && set -x
    # Disable scheduling on the whole cluster. 
    # This will avoid Kubernetes rescheduling jobs while you are shutting down nodes
    printf "Disabling scheduling on cluster nodes:\n"
    vagrant ssh caasp4-master-1 -c 'sudo -H -u sles kubectl get nodes -o name | \
        sudo -H -u sles xargs -I{} kubectl cordon {}'
    # Gracefully shutdown workers
    printf "Shutting down workers:"
    for NUM in $(seq 1 $NWORKERS); do
        printf " caasp4-worker-${NUM}"
        vagrant ssh caasp4-worker-${NUM} -c 'sudo systemctl poweroff' 2> /dev/null
    done
    printf "\n"

    vagrant ssh caasp4-master-1 -c 'sudo -H -u sles bash -c "source /vagrant/utils.sh; wait_for_workers_notready"'

    # Gracefully shutdown masters
    printf "Shutting down masters:"
    for NUM in $(seq 1 $NMASTERS); do
        printf " caasp4-master-${NUM}"
        vagrant ssh caasp4-master-${NUM} -c 'sudo systemctl poweroff' 2>/dev/null
    done
    printf "\n"

    # Gracefully shutdown loadbalancers
    printf "Shutting down loadbalancers:"
    for NUM in $(seq 1 $NLOADBAL); do
        printf " caasp4-lb-${NUM}"
        vagrant ssh caasp4-lb-${NUM} -c 'sudo systemctl poweroff' 2>/dev/null
    done
    printf "\n"

    # Gracefully shutdown storage
    printf "Shutting down storage:"
    for NUM in $(seq 1 $NSTORAGE); do
        printf " caasp4-storage-${NUM}"
        vagrant ssh caasp4-storage-${NUM} -c 'sudo systemctl poweroff' 2>/dev/null
    done
    printf "\n"

    $VERBOSE && set +x
}

function get_dashboard_credentials {
    local NODE_PORT="$(vagrant ssh caasp4-master-1 -c 'sudo -H -u sles kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard -n kube-system' 2>/dev/null)" 
    local NODE_IP="$(vagrant ssh caasp4-master-1 -c 'sudo -H -u sles kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" -n kube-system' 2>/dev/null)"
    local SECRET="$(vagrant ssh caasp4-master-1 -c 'ST=$(sudo -H -u sles kubectl -n kube-system get serviceaccounts admin-user -o jsonpath="{.secrets[0].name}");sudo -H -u sles kubectl -n kube-system get secret ${ST} -o jsonpath="{.data.token}"|base64 -d' 2>/dev/null)"
    printf "Access your dashboard at: https://$NODE_IP:$NODE_PORT/\n"
    printf "Your login token is: ${SECRET}\n"

}

function get_monitoring_credentials {
    local CAASP_DOMAIN="$(sed -n 's/^\s*domain\s*= "\(.*\)".*$/\1/p' Vagrantfile)"
    cat << EOF
You need to add the following to your /etc/hosts file:

#vagrant-caasp4
192.168.121.111     grafana.${CAASP_DOMAIN} prometheus.${CAASP_DOMAIN} prometheus-alert.${CAASP_DOMAIN}


Then point your browser to the web interfaces

Grafana:
url: https://grafana.${CAASP_DOMAIN}
user: admin
pass: $(vagrant ssh caasp4-master-1 -c 'sudo -H -u sles kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo' 2>/dev/null)

Prometheus:
url: https://prometheus.${CAASP_DOMAIN}
user: admin
pass: linux

AlertManager:
url: https://prometheus-alertmanager.${CAASP_DOMAIN}
user: admin
pass: linux
EOF
}


if [[ $# -ne 1 ]]; then
    printf "This tool takes one argument, no more, no less!\n" >&2
    exit 1
fi

case $1 in
    start)
        start_cluster
        ;;
    stop)
        stop_cluster
        ;;
    dashboardInfo)
        get_dashboard_credentials
        ;;
    monitoringInfo)
        get_monitoring_credentials
        ;;
    ?*)
        printf "'$1' is not a valid command\n" >&2
        exit 1
        ;;
esac
