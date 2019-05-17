# dnsmasq [![Build Status](https://drone.kudato.com/api/badges/kudato/baseimage/status.svg)](https://drone.kudato.com/kudato/dnsmasq)

[Dnsmasq](http://thekelleys.org.uk/dnsmasq/doc.html) is a lightweight DNS server for caching (as well as DHCP and TFTP which are not used in this image) for small networks.

This image used [```kudato/baseimage```](https://github.com/kudato/baseimage) as a baseimage and latest stable dnsmasq from [Alpine Linux package repository](https://pkgs.alpinelinux.org/packages?name=dnsmasq&branch=v3.9&repo=main&arch=x86_64).

## Usage

Pull image:
```
docker pull kudato/dnsmasq
```

Run a simple caching server:
```
docker run -d --name dnsmasq \
  --restart=unless-stopped --net=host \
  -e DNSMASQ_DEFAULT_CLOUDFLARE=1.1.1.1 \
  -e DNSMASQ_DEFAULT_GOOGLE=8.8.8.8 \
  kudato/dnsmasq:latest

```

## Environment variables

- ```DNSMASQ_FORWARD_MAX=150``` - set the maximum number of concurrent DNS queries;
- ```DNSMASQ_CACHE_SIZE=150``` - Set the size of dnsmasq's cache, default is 150 names
> Setting the cache size to zero disables caching. Note: huge cache size impacts performance.
- ```DNSMASQ_LOG_QUERIES=True``` - for debugging purposes, log each DNS query as it passes through dnsmasq;
- ```DNSMASQ_ALL_SERVERS=True``` - send all queries to all available servers, the reply from the server which answers first will be returned to the original requester.

### Upstream, Records, Rules and Aliases

One entry = one environment variable. ```<NAME>``` can be any string and is only needed to ensure that the variable names are unique.

- ```DNSMASQ_DEFAULT_<NAME>=x.x.x.x``` - set upstream nameserver;

- ```DNSMASQ_RECORD_A_<NAME>=/<domain>[/<domain>...]/[<ipaddr>]``` - adding A-record;

- ```DNSMASQ_RECORD_MX_<NAME>=<mx name>[[,<hostname>],<preference>]``` - adding MX-record;

- ```DNSMASQ_RECORD_SRV_<NAME>=service.example.com,example.com,389``` - adding SRV-record

- ```DNSMASQ_RECORD_PTR=<name>[,<target>]``` adding PTR-record

- ```DNSMASQ_ALIAS_<NAME>``` - modify IPv4 addresses returned from upstream nameservers, old-ip is replaced by new-ip. If the optional mask is given then any address which matches the masked old-ip will be re-written. So, for instance ```DNSMASQ_ALIAS_<NAME>=1.2.3.0,6.7.8.0,255.255.255.0``` will map ```1.2.3.56``` to ```6.7.8.56``` and ```1.2.3.67``` to ```6.7.8.67```. If the old IP is given as range, then only addresses in the range, rather than a whole subnet, are re-written. So ```DNSMASQ_ALIAS_<NAME>=192.168.0.10-192.168.0.40,10.0.0.0,255.255.255.0``` maps ```192.168.0.10->192.168.0.40``` to ```10.0.0.10->10.0.0.40```.

