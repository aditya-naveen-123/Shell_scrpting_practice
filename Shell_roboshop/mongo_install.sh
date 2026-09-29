#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

sudo mkdir -p $LOGS_FOLDER
sudo chown ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $RPlease run this script with root access $N" | tee -a $LOGS_FILE
    exit 1
fi


VALIDATE() {

    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP $R [ERROR] $2 FAILED $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP $G [INFO] $2 SUCCESS.. $N" | tee -a $LOGS_FILE
    fi

}

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

