#!/bin/bash

DISK_USAGE=$(df -hT | grep -v Filesystem)
USAGE_THRESHOLD=10
SERVER_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
while IFS= read -r line
    do
        USAGE=$(echo $line | awk '{print $6}' | cut -d "%" -f1)
        PARTITION=$(echo $line | awk '{print $7}')

        if [ $USAGE -ge "$USAGE_THRESHOLD" ]; then
            MESSAGE+="High disk usage on $PARTITION: $USAGE <br>"
        fi
done <<< $DISK_USAGE

echo -e $MESSAGE

sh mail.sh "DevOPS_TEAM" "HIGH DISK USAGE" "$SERVER_IP" "$MESSAGE" "adityanaveen19@gmail.com" "High Disk Usage alert"