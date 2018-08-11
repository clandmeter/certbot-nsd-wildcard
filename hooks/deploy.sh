#!/bin/sh

BASEDIR=$(dirname $(readlink -f $0))/..

if [ "$RENEWED_DOMAINS" ]; then
	DOMAINS=$RENEWED_DOMAINS
fi

deploy() {
	local domain=$1 host=$2
    . "$BASEDIR/hosts/$domain/$host"
    ssh $server "mkdir -p \"$path\""
    scp /etc/letsencrypt/live/$domain/* \
        $server:$path
    ssh $server $cmd
}

for domain in $DOMAINS; do
	case $domain in \*.*) continue ;; esac
	for host in $(ls "$BASEDIR/hosts/$domain"); do
		echo "Deploying $domain certs/keys to: $host"
		deploy $domain $host
	done
done

