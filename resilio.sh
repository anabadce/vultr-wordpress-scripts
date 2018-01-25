#!/bin/bash -e

DOWNLOAD_LINK=https://download-cdn.resilio.com/stable/linux-x64/resilio-sync_x64.tar.gz
DOWNLOAD_FILE=resilio-sync_x64.tar.gz
INSTALL_PATH=/root

pushd $INSTALL_PATH
wget $DOWNLOAD_LINK

if pgrep -x rslsync; then
    echo "INFO: Resilio exists, upgrading"     
    echo "INFO: Killing process..."
    killall -w -q rslsync
else
    echo "INFO: Installing Resilio Sync"
fi

tar -zxf resilio-sync_x64.tar.gz
./rslsync

# cleaning
rm -f $DOWNLOAD_FILE

# Start on boot
if [[ -f /etc/cron.d/resilio-sync ]]; then
    echo "INFO: /etc/cron.d/resilio-sync already exist"
else    
    echo "@reboot root $INSTALL_PATH/rslsync" > /etc/cron.d/resilio-sync
    echo "INFO: /etc/cron.d/resilio-sync created"
fi

# Update + restart every month
if [[ -f /etc/cron.d/resilio-sync-update ]]; then
    echo "INFO: /etc/cron.d/resilio-sync-update already exist"
else
    echo "@monthly root /root/vultr-wordpress-scripts/resilio.sh" > /etc/cron.d/resilio-sync-update
    echo "INFO: /etc/cron.d/resilio-sync-update created"
fi


# Done
popd

