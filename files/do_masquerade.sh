#!/bin/sh

# This file was created by Ansible.
# Manual changes will be lost.

# Don't add masquerading rule if it is already exists
iptables -n -t nat -L POSTROUTING | grep -q 'MASQUERADE.*10.8.0' && exit 0 ||:

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
