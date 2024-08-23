#!/bin/bash

if [[ -z ${SERVER_MODE} ]]
then
    echo "Error: Variable 'SERVER_MODE=[primary|secondary]' must be set!"
    exit 1
fi

SERVER_MODE=${SERVER_MODE,,}
if [[ ${SERVER_MODE} != "primary" ]] && [[ ${SERVER_MODE} != "secondary" ]]
then
    echo "Error: SERVER_MODE must be set to 'primary' or 'secondary', was: SERVER_MODE=[${SERVER_MODE}]"
    exit 1
fi

echo "Starting DHCP Server ${SERVER_MODE^^}..."

# Copy config files and setup includes
cp /defaults/dhcpd.conf-${SERVER_MODE} /config/dhcpd.conf
cp /defaults/include.d/*.conf /config/include.d/
for conf_file in $(ls -1 /config/include.d/*.conf); do
    echo "include \"${conf_file}\";" >> /config/dhcpd.conf
done

# Set UID/GID of software user
PGID=${PGID:-101}
PUID=${PUID:-100}
if [[ ${PUID} -ne 100 ]] || [[ ${PGID} -ne 101 ]]
then
    sed -r -i'' "s#^dhcp:x:100:101#dhcp:x:${PUID}:${PGID}#" /etc/passwd
    sed -r -i'' "s#^dhcp:x:101#dhcp:x:${PGID}#" /etc/group
fi

# Final touch and chmod
touch /config/dhcpd.leases
chown -R ${PUID}:${PGID} /config

exec "$@"
