#!/usr/bin/env python
"""
Vagrant external inventory script. Automatically finds the IP of the booted
vagrant vm(s), and returns it under the host group 'vagrant'

Example Vagrant configuration using this script:

    config.vm.provision :ansible do |ansible|
      ansible.playbook = "./provision/your_playbook.yml"
      ansible.inventory_file = "./provision/inventory/vagrant.py"
      ansible.verbose = true
    end
"""

# (c) Copyright 2015-2017 Hewlett Packard Enterprise Development LP
# (c) Copyright 2017 SUSE LLC
# Copyright (C) 2013  Mark Mandel <mark@compoundtheory.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# Thanks to the spacewalk.py inventory script for giving me the basic structure
# of this.
#

import optparse
import os
import re
import subprocess
import sys
try:
    import json
except ImportError:
    import simplejson as json

# Options
# ------------------------------

parser = optparse.OptionParser(
    usage="%prog [options] --list | --host <machine>")
parser.add_option('--list', default=False, dest="list", action="store_true",
                  help="Produce a JSON consumable grouping of Vagrant servers"
                  " for Ansible")
parser.add_option('--host', default=None, dest="host",
                  help="Generate additional host specific details for given"
                  "host for Ansible")
(options, args) = parser.parse_args()


#
# helper functions
#

def list_running_boxes():
    # list all the running boxes
    output = subprocess.check_output(["vagrant", "status"]).split('\n')

    boxes = []

    for line in output:
        matcher = re.search("([^\s]+)[\s]+running \(.+", line)
        if matcher:
            boxes.append(matcher.group(1))

    return boxes


def get_ssh_config(boxname=None, astack_cfg="vagrant-ssh-config"):
    """Gives back a map of the machine's ssh configurations.

    Queries for the ssh-config of all machines in a single run or just
    a single machine if a boxname is provided.
    """

    if os.path.exists(astack_cfg):
        output = [l.rstrip('\n') for l in file(astack_cfg).readlines()]
    else:
        command = ["vagrant", "ssh-config"]
        if boxname:
            command.append(boxname)

        output = subprocess.check_output(command).split('\n')

    config = {}
    output_iter = iter(output)
    for line in output_iter:
        matcher = re.search("Host (.*)$", line)
        if matcher:
            box = matcher.group(1)
            config[box] = {}
            while line.strip() != '':
                matcher = re.search("(  )?([a-zA-Z]+) (.*)", line)
                config[box][matcher.group(2)] = matcher.group(3)
                line = next(output_iter)

    if boxname:
        return config[boxname]
    else:
        return config.values()


if options.list:
    # List out servers that vagrant has running

    hosts = {'vagrant': list_running_boxes()}

    print(json.dumps(hosts))
    sys.exit(0)
elif options.host:
    if re.match("^(clone|task)-[a-zA-Z\-_0-9]+$", options.host):
        # generate fake data for parallel task hosts
        result = {
            'HostName': None,       # must be overridden in ansible
            'User': None,           # must be overridden in ansible
            'Port': None,           # must be overridden in ansible
            'UserKnownHostsFile': "/dev/null",
            'StrictHostKeyChecking': "no",
            'PasswordAuthentication': "no",
            'IdentityFile': None,   # must be overridden in ansible
            'IdentitiesOnly': "yes",
            'LogLevel': "Fatal"
        }
    else:
        # Get out the host details
        result = get_ssh_config(options.host)

        # Pass through the port, in case it's non standard.
        result['ansible_ssh_port'] = result['Port']
        # Pass through the IP address of the host, for ssh connection
        result['ansible_ssh_host'] = result['HostName']
        # Pass through the ssh private key that vagrant assigns to the machine
        result['ansible_ssh_private_key_file'] = result['IdentityFile']
        # Pass through the ssh user to connect with
        result['ansible_ssh_user'] = result['User']

    print(json.dumps(result))
    sys.exit(0)
else:
    # Print out help
    parser.print_help()
    sys.exit(1)
