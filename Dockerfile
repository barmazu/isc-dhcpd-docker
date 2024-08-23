FROM alpine:latest
LABEL description="ISC DHCP Server"

RUN apk --no-cache update && apk --no-cache add bash dhcp
RUN mkdir -p /config/include.d
VOLUME /config

COPY data/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/dhcpd", "-4", \
                        "-d", \
                        "-cf", "/config/dhcpd.conf", \
                        "-lf", "/config/dhcpd.leases", \
                        "-user", "dhcp", \
                        "-group", "dhcp"]
