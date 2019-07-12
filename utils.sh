#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}"/caasp_env.conf

function wait_for_masters_ready {
    printf "Waiting for masters to be ready"
    until [[ $(kubectl get nodes 2>/dev/null | egrep -c "caasp4-master-[0-9]\s+Ready") -eq $NMASTERS ]]; do
         sleep 5
		 printf "."
    done
	printf "\n"
}

function wait_for_workers_ready {
    printf "Waiting for workers to be ready"
    until [[ $(kubectl get nodes 2>/dev/null | egrep -c "caasp4-worker-[0-9]\s+Ready") -eq $NWORKERS ]]; do
         sleep 5
         printf "."
    done
    printf "\n"
}

function wait_for_workers_notready {
    printf "Waiting for workers to be flagged 'NotReady'"
    until [[ $(kubectl get nodes 2>/dev/null | egrep -c "caasp4-worker-[0-9]\s+NotReady") -eq $NWORKERS ]]; do
         sleep 5
         printf "."
    done
    printf "\n"
}
