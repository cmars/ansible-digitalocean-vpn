#!/bin/bash -e

echo "Script started at $(date)"

VPN_HOST=$1
if [ -z "$VPN_HOST" ]; then
	echo "usage: $0 <vpn host>"
fi

VPN_REMOTE_USER=$2
if [ -z "$VPN_REMOTE_USER" ]; then
	VPN_REMOTE_USER=ubuntu
fi

_inv_file=$(mktemp)
trap "rm -f $_inv_file" EXIT
cat >>$_inv_file <<EOF
[vpn]
$VPN_HOST ansible_ssh_user=$VPN_REMOTE_USER

EOF

echo -n "Waiting for host to get up "
while ! ping -c 1 -W 5 $VPN_HOST > /dev/null; do
  echo -n "."
  sleep 1 
done
echo

echo -n "Waiting for SSH server on the host to get up "
while ! netcat -z $VPN_HOST 22; do
  echo -n "."
  sleep 1 
done
sleep 3
echo

ansible-playbook -i $_inv_file vpn.yml
ansible-playbook -i $_inv_file vpn_teardown.yml

which notify-send > /dev/null && notify-send -i call-start 'VPN gateway is online'

echo "Script stopped at $(date)"
