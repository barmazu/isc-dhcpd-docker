#!/bin/bash

if [[ ${UID} -ne 0 ]]; then
    echo "Error: DHCP must run as root!"
    exit 1
fi

if [[ -z ${1} ]]
then
    echo "Error: Parameter '[primary|secondary]' must be set!"
    exit 1
fi

SERVER_MODE=${1,,}
if [[ ${SERVER_MODE} != "primary" ]] && [[ ${SERVER_MODE} != "secondary" ]]
then
    echo "Error: Parameter must be set to 'primary' or 'secondary', was: [${SERVER_MODE}]"
    exit 1
fi

if ! docker start "isc-dhcpd-${SERVER_MODE}"
then
    docker run -d --privileged --net=host \
               -e SERVER_MODE="${SERVER_MODE}" \
               --name="isc-dhcpd-${SERVER_MODE}" \
               -v "$(pwd)/data/defaults":/defaults \
               --restart=always \
               localhost/isc-dhcpd
fi
