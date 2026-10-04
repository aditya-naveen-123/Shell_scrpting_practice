#!/bin/bash

TO_TEAM=$1
ALERT_TYPE=$2
SERVER_IP=$3
MESSAGE=$4
TO_ADDRESS=$5
SUBJECT=$6

FINAL_MESSAGE=$(echo $MESSAGE | sed -e 's/[&/]/\\&/g')
FINAL_BODY=$(sed -e "s/TO_TEAM/$TO_TEAM/g" -e "s/ALERT_TYPE/$ALERT_TYPE/g" -e "s/SERVER_IP/$SERVER_IP/g" -e "s/MESSAGE/$FINAL_MESSAGE/g" template.html)
{
echo "To: $TO_ADDRESS"
echo "Subject: $SUBJECT"
echo "Content-Type: text/html"
echo ""
echo "$FINAL_BODY"
} | msmtp "$TO_ADDRESS"