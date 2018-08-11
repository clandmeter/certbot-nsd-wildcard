#!/bin/sh

BASEDIR=$(dirname $(readlink -f $0))/..
ZONE=$(cat "$BASEDIR"/zone)
ZONEFILE=/etc/nsd/$ZONE.zone
NSDCONF=/etc/nsd/nsd.conf

rc-service nsd stop --quiet

if [ -f "$NSDCONF" ]; then 
	mv "$NSDCONF" "$NSDCONF".bak
fi
if [ -f "$ZONEFILE" ]; then
	mv "$ZONEFILE" "$ZONEFILE".bak
fi
