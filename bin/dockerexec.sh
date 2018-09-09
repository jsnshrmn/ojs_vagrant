#!/usr/bin/env bash

# Fire up systemd and detach.
/usr/lib/systemd/systemd --system --unit=basic.target &

# Generate SSH host keys
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# Fire up SSH
/usr/sbin/sshd

# Keep our container running.
trap : TERM INT
sleep infinity & wait
