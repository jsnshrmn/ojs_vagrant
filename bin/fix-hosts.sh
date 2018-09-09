#!/usr/bin/env bash

# Set up vagrant user ssh keys. These need to live on the vms to have
# reasonable permissions with Windows and vboxsf
mkdir -p  "/home/vagrant/.ssh/machines"
for host in $(ls /vagrant/.vagrant/machines);
do
    [ ! -f "/vagrant/.vagrant/machines/${host}/virtualbox/private_key" ] && continue
    mkdir "/home/vagrant/.ssh/machines/${host}"
    cp -v "/vagrant/.vagrant/machines/${host}/virtualbox/private_key" "/home/vagrant/.ssh/machines/${host}"
    chmod 600 "/home/vagrant/.ssh/machines/${host}/private_key"
    chown -R vagrant:vagrant "/home/vagrant/.ssh/"
done

# copy hosts file provided by vagrant provisioner
cp /vagrant/hosts /etc/hosts
cp /vagrant/ssh.cfg /home/vagrant/.ssh/config
chown vagrant:vagrant /home/vagrant/.ssh/config
chmod 600 /home/vagrant/.ssh/config
