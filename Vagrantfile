# -*- mode: ruby -*-
# vi: set ft=ruby :

##### Config
# Set the project that you would like to build
# by default, we built the trival dev project
vagrant_project ="projects/wpn"
##### End of Config

# What am I doing?
vagrant_command = ARGV[0]
vagrantfile_path = File.dirname(__FILE__)
vagrant_user = ENV.fetch("OULIB_USER", "vagrant")

# Configure Ansible for specified project
ansible_cfg =<<CFG 
[defaults]
roles_path = /vagrant/roles 
host_key_checking = False
log_path = /vagrant/ansible.log
vault_password_file = /vagrant/bin/vaultpw.sh
inventory = /vagrant/#{vagrant_project}/inventory.py
forks = 100
timeout = 30
[ssh_connection]
scp_if_ssh = True
CFG
open(vagrantfile_path+'/ansible.cfg', 'w', crlf_newline: false) do |f|
  f.puts ansible_cfg
end

Vagrant.configure("2") do |config|

# Default configuration for all VMs
config.vm.synced_folder ".", "/vagrant"
config.ssh.forward_agent = true
config.ssh.password = "vagrant"

config.vm.provider "docker" do |d|
  d.build_dir = "."
  d.has_ssh = true
  d.create_args = ["--cap-add", "SYS_ADMIN", "-v", "/run", "-v", "/tmp", "-v", "/sys/fs/cgroup:/sys/fs/cgroup:ro"]
end


# Use a "real" user for interactive logins
if  ['ssh', 'scp'].include? vagrant_command
  # Maybe you want to set this to a real account
  config.ssh.username = vagrant_user
end

# Load and build project containers.
# Use binding.eval to make sure that we're in the right scope.
binding.eval(File.read(File.expand_path(vagrantfile_path+'/'+ vagrant_project+"/vagrant.rb")))

# If we're doing anything that provisions or reprovisions machines, we
# need to start new versions of the config files that need to know
# about our VMs.
if  ['up', 'reload', 'provision'].include? vagrant_command
  # /etc/hosts file for control machine
  File.open(vagrantfile_path+'/hosts', 'w', crlf_newline: false) do |hosts|
    hosts.puts "127.0.0.1	localhost.localdomain localhost"
  end
  # ~/.ssh/config for vagrant user on control machine
  File.open(vagrantfile_path+'/ssh.cfg', 'w', crlf_newline: false) do |hosts|
    hosts.puts "Host *.vagrant.localdomain"
    hosts.puts "  StrictHostKeyChecking no"
  end
end

# Each container writes its ip address and hostname to a common hosts file.
# Docker is fast enough that we may be executing before vagrant share is up.
# Thus the sleep block.
config.vm.provision "shell",
    inline: "while [ ! -f /vagrant/bin/gethostinfo.sh ]; do sleep 1; done; \
        sudo /vagrant/bin/gethostinfo.sh",
    keep_color: "True",
    run: "always"

# Build Ansible control machine and run vagrant playbook
config.vm.define "ansible" do |ansible|
    ansible.vm.hostname = "ansible.vagrant.localdomain"
    ansible.vm.provision "shell",
    inline: "while [ ! -f /vagrant/bin/bootstrap.sh ]; do sleep 1; done; \
        sudo /vagrant/bin/bootstrap.sh #{vagrant_project}",
        keep_color: "True"
  end
end
