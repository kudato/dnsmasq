FROM kudato/baseimage:3.9

ENV \
    DNSMASQ_INIT_SH=/usr/bin/dnsmasq-init.sh \
    DNSMASQ_HEALTHCHECK_UDP=127.0.0.1:53

COPY dnsmasq.conf /etc/
COPY init.sh ${DNSMASQ_INIT_SH}
RUN apk add --no-cache dnsmasq

CMD ["/usr/sbin/dnsmasq", "-C", "/etc/dnsmasq.conf", "-d"]
