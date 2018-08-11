#!/bin/sh -e

AUTHSERVER=https://acme-v02.api.letsencrypt.org/directory
STAGINGSERVER=https://acme-staging-v02.api.letsencrypt.org/directory
BASEDIR=$(dirname $(readlink -f $0))

create_cert() {
	certbot certonly \
		--manual \
		--agree-tos \
		--non-interactive \
		--server $AUTHSERVER \
		--manual-auth-hook "$BASEDIR"/hooks/auth-hook.sh \
		--manual-cleanup-hook "$BASEDIR"/hooks/cleanup_hook.sh \
		--manual-public-ip-logging-ok \
		--preferred-challenges=dns \
		--email $EMAIL \
		--domains "$DOMAIN,*.$DOMAIN" \
		$OPTIONS
}

deploy() {
	if [ "$DEPLOY" != "false" ]; then
		echo "Deploying certs/keys..."
		DOMAINS=$DOMAIN "$BASEDIR"/hooks/deploy.sh
	fi
}

set_zone() {
	local zone
	printf "Enter zone-name: "
	read zone
	echo "$zone" > "$BASEDIR"/zone
	echo "Setting zone-name to $zone."
	echo "Run setup -z zone-name to change it."
}

usage() {
	cat <<- EOF
	Setup wildcard certificates with certbot (using DNS-01 and a local DNS server).

	Usage: $0 [-d domain] [-s]

	Options:
	    -d Domain name to use
	    -s Use ACME starging server
	    -n Do not deploy
	    -h This help text
	    -z Set or update zone-name
	EOF
	exit 0
}

staging() {
	AUTHSERVER=$STAGINGSERVER
	OPTIONS="--force-renewal"
	echo "WARNING: Using staging server."
}

[ $# = 0 ] && usage

while getopts "d:hnsz" opt; do
	case $opt in
		d) DOMAIN=$OPTARG;;
		h) usage;;
		n) DEPLOY=false;;
		s) staging;;
		z) set_zone; exit 0;;
		*) usage;;
	esac
done

shift "$((OPTIND-1))"

[ ! -s "$BASEDIR"/zone ] && set_zone
ZONE=$(cat "$BASEDIR"/zone)
ZONEFILE=/etc/nsd/$ZONE.zone
EMAIL=info@${ZONE#*.}

create_cert && deploy

[ -f "$ZONEFILE" ] && mv "$ZONEFILE" "$ZONEFILE".bak
