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

get_instance_id() {
    INSTANCE_NAME=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=roboshop-$INSTANCE_NAME" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text
}
for instance in $@
do
    INSTANCEID=$(get_instance_id $instance)
    if [ $ACTION == "create" ]; then
        if [ $INSTANCEID == "None" ]; then
            echo "Launching instance 'roboshop-$instance'"
            INSTANCEID=$(
            aws ec2 run-instances \
            --image-id ami-0220d79f3f480ecf5 \
            --count 1 \
            --instance-type t3.micro \
            --security-groups "roboshop-common" "roboshop-$instance" \
            --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value="roboshop-'$instance'"}]' \
            --query 'Instances[0].InstanceId' \
            --output text)
            echo "Launched new instance $INSTANCEID"          
        else
            echo "Instance roboshop-$instance is already running: $INSTANCEID"
        fi
        if [ $instance == "frontend" ]; then
                    IP=$(aws ec2 describe-instances --instance-ids $INSTANCEID \
                        --query 'Reservations[*].Instances[*].PublicIpAddress' \
                        --output text 
                ) 
                    R53RECORD="$DOMAIN_NAME"
            else
                    IP=$(aws ec2 describe-instances  --instance-ids $INSTANCEID \
                    --query 'Reservations[*].Instances[*].PrivateIpAddress' \
                    --output text 
                ) 
                    R53RECORD="$instance.$DOMAIN_NAME"
            fi

            aws route53 change-resource-record-sets \
            --hosted-zone-id $ZONEID \
            --change-batch '
            {
            "Comment": "Updating DNS record",
            "Changes": [
                            {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": "'$R53RECORD'",
                            "Type": "A",
                            "TTL": 1,
                            "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                            ]
                        }
                        }
                    ]
             }' 
            echo "Updated Route 53 record for $instance" 

    else
        if [ $ACTION == "None" ]; then
            echo "$instance is already destoryed nothing to do"
        else
            aws ec2 terminate-instances --instance-ids $INSTANCEID
            echo "Terminating.....; $instance"
        fi
    fi
done