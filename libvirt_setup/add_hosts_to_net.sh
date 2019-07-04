NET="vagrant-libvirt"
export LIBVIRT_DEFAULT_URI=qemu:///system
virsh net-start ${NET}
# API load balancers
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:03:01" ip="192.168.121.111"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:03:02" ip="192.168.121.112"/>' \
      --live --config --parent-index 0

# masters
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:01:01" ip="192.168.121.120"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:01:02" ip="192.168.121.121"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:01:03" ip="192.168.121.122"/>' \
      --live --config --parent-index 0

# workers
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:02:01" ip="192.168.121.130"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:02:02" ip="192.168.121.131"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:02:03" ip="192.168.121.132"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:02:04" ip="192.168.121.133"/>' \
      --live --config --parent-index 0
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:02:05" ip="192.168.121.134"/>' \
      --live --config --parent-index 0

# NFS
virsh net-update ${NET} add-last ip-dhcp-host \
      '<host mac="52:50:05:AA:04:01" ip="192.168.121.140"/>' \
      --live --config --parent-index 0

# API load balancers
virsh net-update ${NET} add dns-host '<host ip="192.168.121.111"><hostname>caasp4-lb-1.suselab.com</hostname><hostname>caasp4-lb-1</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.112"><hostname>caasp4-lb-2.suselab.com</hostname><hostname>caasp4-lb-2</hostname></host>' --live --config
# masters
virsh net-update ${NET} add dns-host '<host ip="192.168.121.120"><hostname>caasp4-master-1.suselab.com</hostname><hostname>caasp4-master-1</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.121"><hostname>caasp4-master-2.suselab.com</hostname><hostname>caasp4-master-2</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.122"><hostname>caasp4-master-3.suselab.com</hostname><hostname>caasp4-master-3</hostname></host>' --live --config
# workers
virsh net-update ${NET} add dns-host '<host ip="192.168.121.130"><hostname>caasp4-worker-1.suselab.com</hostname><hostname>caasp4-worker-1</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.131"><hostname>caasp4-worker-2.suselab.com</hostname><hostname>caasp4-worker-2</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.132"><hostname>caasp4-worker-3.suselab.com</hostname><hostname>caasp4-worker-3</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.133"><hostname>caasp4-worker-4.suselab.com</hostname><hostname>caasp4-worker-4</hostname></host>' --live --config
virsh net-update ${NET} add dns-host '<host ip="192.168.121.134"><hostname>caasp4-worker-5.suselab.com</hostname><hostname>caasp4-worker-5</hostname></host>' --live --config
# NFS
virsh net-update ${NET} add dns-host '<host ip="192.168.121.140"><hostname>caasp4-storage-1.suselab.com</hostname><hostname>caasp4-storage-1</hostname></host>' --live --config
