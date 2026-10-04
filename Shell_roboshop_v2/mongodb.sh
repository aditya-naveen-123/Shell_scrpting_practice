#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y  &>> $LOGS_FILE
VALIDATE $? "Installing Mongo DB"

systemctl enable --now mongod &>> $LOGS_FILE
VALIDATE $? "Starting and enabling MongoDB"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "Adding remote connections to mongoDB"

systemctl restart mongod
VALIDATE $? "Restarting Monog DB"

print_total_time