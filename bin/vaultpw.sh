#!/bin/bash

VAULT_PW="/vagrant/vault_password.txt"
[ -f "$VAULT_PW" ] || exit 1

cat "$VAULT_PW"
