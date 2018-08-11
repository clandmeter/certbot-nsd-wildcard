certbot-nsd-wildcard
================
Generate letsencrypt wildcard certificates via local
[NSD](https://www.nlnetlabs.nl/projects/nsd/about/) server

## Description

This is a collection of simple [POSIX](http://www.opengroup.org/austin/papers/posix_faq.html)
shell scripts which will locally configure [NSD](https://www.nlnetlabs.nl/projects/nsd/about/)
name server and setup [Certbot](https://certbot.eff.org/) to validate via our local name server.


## Requirements

    apk add nsd

## Setup

### DNS

This setup needs two name servers. The locally configured name server by these
scripts and a remote name server which hosts your domains zonefile.

#### Remote

You need to register your local name server in your global zone file by adding
the following lines:

    ns-acme			IN		A		xxx.xxx.xxx.xxx
    acme					NS		ns-acme.domain.tld.
    _acme-challenge		IN		CNAME		acme-domain-tld.host.domain.tld

#### Local

The authentication hook will automatically generate the zone file and the
[NSD](https://www.nlnetlabs.nl/projects/nsd/about/) configuration file for you.

#### Domains

You can add additional domains to generate certs/keys via this local name server.
Simply add a CNAME to point to this name server like in the Global section above.

### Deployment

To automatically deploy certificates create a text file:

    hosts/$domain/$hostname

with the following:

    local server=user@host
    local path=path-to-store-certs
    local cmd="post command to execute on remote"

#### Remote

Make sure the user on the remote server can execute the command.
To reload NGINX with OpenRC add this to /etc/sudoers.d/acme

    acme ALL=(root) NOPASSWD: /sbin/rc-service nginx reload

### Create certificates

Run `setup.sh` to setup [Certbot](https://certbot.eff.org/) for your wildcard
domain. This will automatically deploy your certificates and keys to your remote
servers configured in the deployment sections.

### Renew certificates

Add a weekly cronjob to check if certificates needs renew.

    ln -s /path/to/cron.sh /etc/periodic/weekly/certbot-renew

