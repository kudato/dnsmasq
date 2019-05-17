#!/bin/bash

export DNSMASQ_CONFIG=/etc/dnsmasq.conf

# Set the maximum number of concurrent DNS queries.
# The default value is 150.
if [ -n "${DNSMASQ_FORWARD_MAX}" ]; then
    sed -i "s|#{{MAX}}|dns-forward-max=${DNSMASQ_FORWARD_MAX}|g" ${DNSMASQ_CONFIG}
fi

# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
if [ "${DNSMASQ_LOG_QUERIES}" == "True" ]; then
    sed -i "s|#log-queries|log-queries|g" ${DNSMASQ_CONFIG}
fi

# Set the size of dnsmasq's cache. The default is 150 names.
# Setting the cache size to zero disables caching.
# Note: huge cache size impacts performance.
if [ -n "${DNSMASQ_CACHE_SIZE}" ]; then
    sed -i "s|#{{CACHE}}|cache-size=${DNSMASQ_CACHE_SIZE}|g" ${DNSMASQ_CONFIG}
fi

# By default, when dnsmasq has more than one upstream server available, it will
# send queries to just one server. Setting this flag forces dnsmasq to send all
# queries to all available servers. The reply from the server which answers first
# will be returned to the original requester.
if [ -n "${DNSMASQ_ALL_SERVERS}" ]; then
    sed -i "s|#all-servers|all-servers|g" ${DNSMASQ_CONFIG}
fi

# Use also specific hosts file for resolving domains.
if [ -n "${DNSMASQ_HOSTS_FILE}" ]; then
    sed -i "s|#{{HOSTS}}|addn-hosts=${DNSMASQ_HOSTS_FILE}|g" ${DNSMASQ_CONFIG}
fi
# -------------------------------------------------------------
dnsmasq_env() {
    echo $(env | grep DNSMASQ | grep $1 | sort)
}

env_value() { # $1 is 'EXAMPLE=value' -> "value" returned
    echo "$1" | sed -r 's/[^=]+//' | sed 's|=||g'
}

# The upstream DNS servers.
dnsmasq_default() {
    local result=""
    for ns in $(dnsmasq_env DEFAULT)
    do
          local result="${result}server=$(env_value "$ns")\n"
    done
    echo $result
}
sed -i "s|{{DEFAULT}}|$(dnsmasq_default)|g" ${DNSMASQ_CONFIG}

# Rules for specific domains.
dnsmasq_rules() {
    local result=""
    for ns in $(dnsmasq_env RULE)
    do
      local result="${result}server=$(env_value "$ns")\n"
    done
    echo $result
}
if [ $(dnsmasq_rules) ]; then
    sed -i "s|#{{RULES}}|$(dnsmasq_rules)|g" ${DNSMASQ_CONFIG}
fi

# DNS records:

# A
dnsmasq_a() {
    local result=""
    for record in $(dnsmasq_env RECORD | grep _A)
    do
      local result="${result}address=$(env_value "$record")\n"
    done
    echo $result
}
if [ $(dnsmasq_a) ]; then
    sed -i "s|#{{A}}|$(dnsmasq_a)|g" ${DNSMASQ_CONFIG}
fi

# MX
dnsmasq_mx() {
    local result=""
    for record in $(dnsmasq_env RECORD | grep MX)
    do
      local result="${result}mx-host=$(env_value $record)\n"
    done
    echo $result
}
if [ $(dnsmasq_mx) ]; then
    sed -i "s|#{{MX}}|$(dnsmasq_mx)|g" ${DNSMASQ_CONFIG}
fi

# SRV
dnsmasq_srv() {
    local result=""
    for record in $(dnsmasq_env RECORD | grep SRV)
    do
      local result="${result}srv-host=$(env_value $record)\n"
    done
    echo $result
}
if [ $(dnsmasq_srv) ]; then
    sed -i "s|#{{SRV}}|$(dnsmasq_srv)|g" ${DNSMASQ_CONFIG}
fi

# PRT
dnsmasq_ptr() {
    local result=""
    for record in $(dnsmasq_env RECORD | grep PRT)
    do
      local result="${result}ptr-record=$(env_value $record)\n"
    done
    echo $result
}
if [ $(dnsmasq_ptr) ]; then
    sed -i "s|#{{PTR}}|$(dnsmasq_ptr)|g" ${DNSMASQ_CONFIG}
fi

# If you want to fix up DNS results from upstream servers, use the
# alias option. This only works for IPv4!
dnsmasq_alias() {
    local result=""
    for record in $(dnsmasq_env ALIAS)
    do
      local result="${result}server=$(env_value $record)\n"
    done
    echo $result
}
if [ $(dnsmasq_alias) ]; then
    sed -i "s|#{{ALIAS}}|$(dnsmasq_alias)|g" ${DNSMASQ_CONFIG}
fi

# Check config
/usr/sbin/dnsmasq -C ${DNSMASQ_CONFIG} --test
