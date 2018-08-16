#!/bin/bash -e

# Setting up cron jobs for updates and so on...

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi



# ======== CRON Function ========

function setup_cron () {
    SCRIPT_NAME=$1
    CRON_REPEAT=$2
    SCRIPT_PATH=$(dirname $(pwd))
    chmod +x $SCRIPT_PATH/${SCRIPT_NAME}.sh
    if [[ -f /etc/cron.d/6-$SCRIPT_NAME ]]; then
        echo "INFO: cron.d $SCRIPT_NAME script already configured."
    else
        echo "$CRON_REPEAT root $SCRIPT_PATH/${SCRIPT_NAME}.sh > /dev/null" > "/etc/cron.d/6-$SCRIPT_NAME"
        echo "INFO: cron.d script to run $CRON_REPEAT $SCRIPT_PATH/${SCRIPT_NAME}.sh"
    fi
}

# ======== Backups ========

SCRIPT_NAME="create_backup"
CRON_REPEAT="@daily"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ======== wordpress update ========

SCRIPT_NAME="wordpress-cli-update"
CRON_REPEAT="@weekly"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ======== server update ========

SCRIPT_NAME="server-update"
CRON_REPEAT="@weekly"
setup_cron $SCRIPT_NAME $CRON_REPEAT

# ======== certbot update ========

SCRIPT_NAME="certbot-update"
CRON_REPEAT="@weekly"
setup_cron $SCRIPT_NAME $CRON_REPEAT

echo "INFO: Crons:"
ls -ltr /etc/cron.d | grep -E "(backup|-update)"

echo "INFO: Done"

