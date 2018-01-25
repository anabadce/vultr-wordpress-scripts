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

rm -f $DOWNLOAD_FILE

popd

