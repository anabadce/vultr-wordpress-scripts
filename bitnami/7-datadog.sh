#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root" 
    exit 1
fi

if [[ -z $1 ]]; then
    echo "Usage: $(basename "$0") DATADOG_KEY"
    exit 1
else
    DATADOG_KEY=$1
fi

DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=$DATADOG_KEY DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

echo "INFO: Done"
echo "INFO: Run \"sudo datadog-agent status\" to check"
