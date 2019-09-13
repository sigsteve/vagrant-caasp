#!/bin/bash

# sudo this file

echo "alias ll='ls -al'" >> ~sles/.bashrc

zypper ar http://download.suse.de/ibs/SUSE:/SLE-15-SP1:/GA/standard SLE15-SP1-GA
zypper ar http://download.suse.de/ibs/SUSE:/SLE-15-SP1:/Update/standard/ SLE15-SP1-Update

zypper ar http://download.suse.de/install/SLP/SLE-15-SP1-Module-Development-Tools-GM/x86_64/DVD1/ SLE15-DEV-DVD1
zypper ar http://download.suse.de/install/SLP/SLE-15-SP1-Module-Development-Tools-GM/x86_64/DVD2/ SLE15-DEV-DVD2
zypper ar http://download.suse.de/install/SLP/SLE-15-SP1-Module-Development-Tools-GM/x86_64/DVD3/ SLE15-DEV-DVD3

zypper ar http://download.suse.de/install/SLP/SLE-15-SP1-Module-Basesystem-GM/x86_64/DVD1/ SLE15-SP1-BASE1
zypper ar http://download.suse.de/install/SLP/SLE-15-SP1-Module-Basesystem-GM/x86_64/DVD2/ SLE15-SP1-BASE2
zypper ar http://download.suse.de/install/SLP/SLE-15-SP1-Module-Basesystem-GM/x86_64/DVD3/ SLE15-SP1-BASE3
