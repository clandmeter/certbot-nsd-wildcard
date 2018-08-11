#!/bin/sh

BASEDIR=$(dirname $(readlink -f $0))

certbot renew --deploy-hook "$BASEDIR"/hooks/deploy.sh

