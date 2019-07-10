#!/bin/bash
BRIDGE=$(virsh net-info vagrant-libvirt|sed -n 's/^Bridge:\s*\(.*\).*/\1/p')
if [ ! -z "${BRIDGE}" ]; then
	echo "Found vagrant-libvirt bridge device: ${BRIDGE}"
else
	echo "Unable to determine bridge... Automation failed you."
	exit 1
fi

FWSTATE="unknown"
if [ -x /usr/bin/firewall-cmd ]; then
	FWSTATE=$(firewall-cmd --state)
else
	exit 0
fi

ZONE="vagrant-caasp"
FWCMDRC=$(firewall-cmd --info-zone ${ZONE} >/dev/null 2>&1;echo $?)
if [ "${FWCMDRC}" -eq 0 ]; then
	echo "Firewall zone ${ZONE} already configured"
	exit 0
fi

if [ "${FWSTATE}" == "running" ]; then
    echo "Updating firewall configuration for ${BRIDGE}"
   	set -x
	firewall-cmd --permanent --new-zone=${ZONE}
	firewall-cmd --zone=${ZONE} --permanent --add-interface=${BRIDGE}
	firewall-cmd --zone=${ZONE} --permanent --set-target=ACCEPT
	firewall-cmd --reload
	set +x
   	exit 0
else
	echo "Firewall not running?"
	exit 0
fi
