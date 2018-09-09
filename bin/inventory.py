#!/usr/bin/env python2

import json
import os

# Get current directory
cwd = os.path.dirname(os.path.abspath(__file__))
# Ansible inventory skeleton for Vagrant use
inventory = {
    'vagrant' : {
        'hosts' : [],
    }
}

# Read vagrant hosts from Vagrantfile
with open( "/vagrant/Vagrantfile", "r") as hosts:
    for line in hosts:
        if( "vm.hostname = " in line and ".vagrant.localdomain" in line):
            my_host = line.split("=")[1].replace('"', '').strip()
            inventory['vagrant']['hosts'].append(my_host)

# Read vagrant hosts from project-specific vagrant.rb
with open( cwd + "/vagrant.rb", "r") as hosts:
    for line in hosts:
        if( "vagrant.localdomain" in line):
            my_host = line.split("=")[1].replace('"', '').strip()
            inventory['vagrant']['hosts'].append(my_host)

print json.dumps(inventory)
