#!/bin/bash -e

# https://docs.bitnami.com/bch/apps/wordpress/#how-to-force-https-redirection-with-apache

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

/opt/bitnami/apache2/bnconfig --disable_banner 1

/opt/bitnami/ctlscript.sh restart apache

echo "INFO: Done"

