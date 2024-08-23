#!/bin/bash

if [[ ${UID} -ne 0 ]]; then
    echo "Error: DHCP must run as root!"
    exit 1
fi

docker build -t localhost/isc-dhcpd .
