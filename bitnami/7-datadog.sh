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

DD_CONF_PATH=/etc/datadog-agent/conf.d
DD_API_KEY=$DATADOG_KEY bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"

cat <<EOT > $DD_CONF_PATH/disk.d/disk.yaml
init_config:

instances:
  - use_mount: false

mount_point_blacklist:
  - devtmpfs
  - tmpfs
  - udev
  - /dev/loop0
  - /dev/loop1
  - /dev/loop2
  - /dev/loop3
EOT

echo "INFO: Done"
echo "INFO: Run \"sudo datadog-agent status\" to check"
