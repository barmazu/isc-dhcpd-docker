#!/bin/bash

set -eE

if ! command -v yq >/dev/null 2>&1; then
    echo "Error: yq command not found."
    echo "Make sure you have go-yq (https://github.com/mikefarah/yq/releases) in the PATH"
    exit 1
fi

#
# Make sure pihole.toml is rw by system user, eg sudo setfacl -m u:user:rwx etc-pihole/pihole.toml
#
sudo setfacl -m u:pi:rwx etc-pihole/pihole.toml
ssh pihole2 'sudo setfacl -m u:pi:rwx ~/etc-pihole/pihole.toml'

# SYNC PIHOLE
scp ~/etc-pihole/pihole.toml  pihole2:/home/pi/etc-pihole/pihole.toml

# ISC DHCP
yq -oy .dhcp.hosts[] etc-pihole/pihole.toml > ~/etc-dnsmasq.d/04-pihole-static-dhcp.conf
scp ~/etc-dnsmasq.d/04-pihole-static-dhcp.conf pihole2:~/etc-dnsmasq.d/04-pihole-static-dhcp.conf
~/isc-dhcpd/gen-static-hosts.sh && ssh pihole2 '~/isc-dhcpd/gen-static-hosts.sh'

cat ~/isc-dhcpd/data/defaults/include.d/01-dhcpd-static-hosts.conf
ssh pihole2 'cat ~/isc-dhcpd/data/defaults/include.d/01-dhcpd-static-hosts.conf'

sudo docker restart isc-dhcpd-primary && docker restart pihole
sleep 10
ssh pihole2 'sudo docker restart isc-dhcpd-secondary && docker restart pihole'
