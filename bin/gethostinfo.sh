#!/usr/bin/env bash

# Get ip address and hostname, write it to various config files
IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
HOSTNAME=$(hostname)
VAGRANTNAME=$(hostname | cut -d"." -f 1)

# Ends up in /etc/hosts on ansible machine
echo "${IP}	${HOSTNAME}" >> /vagrant/hosts

# Ends up in /vagrant/.ssh/config on ansible machine
echo "Host ${HOSTNAME}" >> /vagrant/ssh.cfg
echo "  IdentityFile /home/vagrant/.ssh/machines/${VAGRANTNAME}/private_key" >> /vagrant/ssh.cfg
