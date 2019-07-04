. caasp_env.conf

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

if [ "${1}" == "--full" ]; then
    vagrant ssh caasp4-master-1 -c 'sudo su - sles -c /vagrant/deploy/99.run-all.sh'
fi

echo "Happy CaaSPing!"
echo "vagrant ssh caasp4-master-1"
echo "sudo su - sles"
echo "See scripts in the /vagrant/deploy directory for deployment guide steps"
echo "...or run $0 --full to have your cluster auto-deployed"
