#!/bin/bash

# Generate ISC DHCPD Static Hosts Entries form DNSMASQ file
# Input:
DNSMASQ_FILE=${1:-'/home/pi/etc-dnsmasq.d/04-pihole-static-dhcp.conf'}
# Output:
ISCDHCP_FILE=${2:-'/home/pi/isc-dhcpd/data/defaults/include.d/01-dhcpd-static-hosts.conf'}

if [[ -s ${DNSMASQ_FILE} ]]; then
    if [[ -s ${ISCDHCP_FILE} ]]; then
        ISCDHCP_FILE_BAK="${ISCDHCP_FILE}.bak_$(date +%s)"
        mv "${ISCDHCP_FILE}" "${ISCDHCP_FILE_BAK}"
        echo "Current ${ISCDHCP_FILE} saved as ${ISCDHCP_FILE_BAK}"
    else
        echo "ISC DHCP file does not exit yet, creating..."
        touch "${ISCDHCP_FILE}"
    fi
    echo "Converting DNSMASQ static DHCP into ISC DHCP format"
    if awk -F'[=,]' '{printf "host %s {\n\thardware ethernet %s;\n\tfixed-address %s;\n}\n",$4,$2,$3}' < <(sort -t'.' -k3,3n -k4,4n "${DNSMASQ_FILE}") > "${ISCDHCP_FILE}"; then
        echo "File ${ISCDHCP_FILE} has been updated"
        exit 0
    else
        echo "Error: Something went wrong upon file conversion (worng source format?)"
        if [[ -e ${ISCDHCP_FILE_BAK} ]]; then
            echo "Restoring previous ISC DHCP static hosts file..."
            if mv "${ISCDHCP_FILE}" "${ISCDHCP_FILE}".failed && mv "${ISCDHCP_FILE_BAK}" "${ISCDHCP_FILE}"; then
                echo "Failed conversion attempt saved as ${ISCDHCP_FILE}.failed for further investigation"
                echo "Previuos static hosts file has been restored in-place"
                exit 1
            else
                echo "Unable to restore backup, please inspect files manually, before restring the server"
                exit 1
            fi
        else
            echo "No backup file exists, inspect files or clean up manually"
            exit 1
        fi
    fi
else
    echo "ERROR: ${DNSMASQ_FILE} is empty or does not exist!"
    echo "No changes made."
    exit 1
fi
