#!/usr/bin/env bash

set -Eeo pipefail

# Find out the os family.
dist=$(/vagrant/bin/get_dist.py)

# Install os-specific dependencies and set appropriate group name for admins.
if [ "$dist" == "centos" ] || [ "$dist" == "redhat" ]
then
  admingroup="wheel"

  # Clean metadata in case of old mirrors etc.
  yum clean metadata || :
  yum check-update || :
  # Install epel repo.
  yum install -y epel-release
  # Install actual dependencies.
  yum install -y git gcc openssl-devel python36-devel sshpass
  # Set an alternative for python3.
  alternatives --install /usr/bin/python3 python3 /usr/bin/python36 1
fi

if [ "$dist" == "debian" ] || [ "$dist" == "Ubuntu" ]
then
  admingroup="sudo"
  apt install -y git gcc libffi-dev libssl-dev python3-venv sshpass
fi

# Copy /etc/hosts file and set up ssh keys for vagrant user
/vagrant/bin/fix-hosts.sh

python3 -m venv /opt/venv
source /opt/venv/bin/activate
python -m pip install --upgrade setuptools
python -m pip install --upgrade pip
python -m pip install -r /vagrant/requirements.txt

# Create the default ansible config folder (pip install doesn't).
mkdir -pv /etc/ansible

# create ansible vault secret if one doesn't exist.
stat /vagrant/vault_password.txt &>/dev/null || bash -c '< /dev/urandom tr -dc "a-zA-Z0-9~!@#$%^&*_-" | head -c${1:-254};echo;' > /vagrant/vault_password.txt

# ansible complains if this file is on the windows share because permissions
cp /vagrant/ansible.cfg /etc/ansible/ansible.cfg
chown root:${admingroup} /etc/ansible/ansible.cfg
chmod 644 /etc/ansible/ansible.cfg

# ansible uses the inventory path to locate group and host vars so we have to
# make sure the script is in the project folder
cp "/vagrant/bin/inventory.py" "/vagrant/${1}"

# Install default ansible roles
# Or project-specific roles if present
VAGRANT_REQUIREMENTS='/vagrant/requirements.yml'
if [ -f "/vagrant/${1}/requirements.yml" ]; then
    VAGRANT_REQUIREMENTS="/vagrant/${1}/requirements.yml"
fi
ansible-galaxy install -r "${VAGRANT_REQUIREMENTS}" --force

# run ansible
sudo -u vagrant bash -c "
# Keep colors intact
source /opt/venv/bin/activate
export PYTHONUNBUFFERED=1
export ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
export ANSIBLE_FORCE_COLOR=1
ansible-playbook --user=vagrant --vault-id /vagrant/bin/vaultpw.sh /vagrant/${1}/playbooks/vagrant.yml --skip-tags 'selinux'
"
