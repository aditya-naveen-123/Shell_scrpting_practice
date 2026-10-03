#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONEID="Z00124091EBFH7C8X3X7"
DOMAIN_NAME="adityabuilds.fun"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $# -lt 2 ]; then
    echo -e "[ERROR] $R This script needs atleast 2 args to run $N"
    echo -e "$Y [INFO] - USAGE : $0 [create/delete] [instance1] [instance2] etc.. $N"
    exit 1
fi

ACTION=$1
shift
if [ "$ACTION" != "create" ] && [ "$ACTION" != "delete" ]; then
    echo -e "$R [ERROR]  First argument should always be either <create> or <delete> $N"
    echo -e "$Y [INFO] - USAGE : $0 [create/destrroy] [instance1] [instance2] etc.. $N"
    exit 1
fi

if [ "$ACTION"]