#!/bin/bash

# get the current folder
# change to any location needed, currently CURRENT folder
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Location of the IP address - WAN IP file
# Change to any location with rw permission
# $SCRIPT_DIR/$WANIPTXT

# Location of the files
# Change to any location with rw permission
# Log file
WANIPLOG="wanip.log"
# Location of the variable
# IP file
WANIPTXT="wanip.txt"

# Path to your Nginx Proxy Manager proxy_host directory
# Example
# PROXYHOSTCONFIG="/srv/docker/nginxproxymanager/data/nginx/proxy_host"
PROXYHOSTCONFIG="CHANGE ME"

# Number of lines to keep
NRLINES=1000

############################################################
# Do not change after this line 
echo "$(date +"%Y-%m-%d %H:%M:%S") - Check started" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
#Get the current WAN IP address
NEW_WAN_IP=$(curl -s https://icanhazip.com)

#check if the WAN IP file exists, create it with the WAN IP if not.
if test -f "$SCRIPT_DIR"/"$WANIPTXT"; then
    OLD_WAN_IP=$(cat "$SCRIPT_DIR"/"$WANIPTXT")
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Detected OLD IP: $OLD_WAN_IP" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
else
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - First run (no previus WAN IP detected)" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
fi

if [ "$NEW_WAN_IP" == "$OLD_WAN_IP" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - WAN IP has not changed since last run." | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Detected NEW IP: $NEW_WAN_IP" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Updating WAN IP file" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
    echo $NEW_WAN_IP > "$SCRIPT_DIR"/$WANIPTXT

    ###############################
    # Ngingx Proxy Manager
    echo "$(date +"%Y-%m-%d %H:%M:%S") - WAN IP has changed! Updating nginx configs..." | tee -a "$SCRIPT_DIR"/"$WANIPLOG"

    # for each file in directory 
    for FILE in "$PROXYHOSTCONFIG"/*; do
        if [ -f "$FILE" ]; then
            # Use sed to replace the old IP with the new IP
            sed -i "s/$OLD_WAN_IP/$NEW_WAN_IP/g" "$FILE"
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Updated $FILE" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
            
        fi
    done
    # Reload NGINX Proxy Manager container
    docker exec nginxproxymanager /bin/bash -c "/usr/sbin/nginx -s reload"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - NGINX Proxy Manager restarted. End" | tee -a "$SCRIPT_DIR"/"$WANIPLOG"
fi
echo "$(tail -$NRLINES "$SCRIPT_DIR"/"$WANIPLOG")" > "$SCRIPT_DIR"/"$WANIPLOG"
