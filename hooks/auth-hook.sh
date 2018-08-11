#!/bin/sh

BASEDIR=$(dirname $(readlink -f $0))/..
ZONE=$(cat "$BASEDIR"/zone)

write_conf() {
	cat <<- EOF > "/etc/nsd/nsd.conf"
	server:
	    ip-address: 0.0.0.0
	    ip4-only: yes
	    hide-version: yes
	    identity: ""
	    zonesdir: "/etc/nsd"

	zone:
	    name: $ZONE
	    zonefile: $ZONE.zone
	EOF
}

write_zone() {
	cat <<- EOF > "/etc/nsd/$ZONE.zone"
	\$ORIGIN $ZONE.
	\$TTL 1m

	@ IN SOA ns-$ZONE. dns-admin.$ZONE. (
	    $(date +%y%m%d%H%M)		; serial
	    12h				; refresh
	    2h				; retry
	    2w				; expire
	    1h				; min TTL
	    )

	EOF
}

[ ! -f "/etc/nsd/nsd.conf" ] && write_conf
[ ! -f "/etc/nsd/$ZONE.zone" ] && write_zone

echo "acme-${CERTBOT_DOMAIN//./-}	IN	TXT	\"$CERTBOT_VALIDATION\"" >> "/etc/nsd/$ZONE.zone"

rc-service nsd restart --quiet

sleep 10

