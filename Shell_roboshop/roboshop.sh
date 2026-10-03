#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
ZONEID="Z00124091EBFH7C8X3X7"
DOMAIN_NAME="adityabuilds.fun"


for instance in $@
do
    echo "Launching $instance"
    INSTANCEID=$(
        aws ec2 run-instances \
--image-id ami-0220d79f3f480ecf5 \
--count 1 \
 --instance-type t3.micro \
 --security-groups "roboshop-common" "roboshop-$instance" \
 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value="roboshop-'$instance'"}]' \
 --query 'Instances[0].InstanceId' \
 --output text 

    )
echo "Instance Id is : $INSTANCEID"

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
}
'

done