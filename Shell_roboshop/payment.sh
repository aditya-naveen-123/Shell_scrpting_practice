#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SQL_DOMAIN="mysql.adityabuilds.fun"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SCRIPT_DIR=$PWD

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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user with no login"
else
    echo -e "$Y [INFO] User already created....SKIPPINGGG $N"
fi

rm -rf /app &>$LOGS_FILE
VALIDATE $? "Removing existing app directory"

rm -rf  /tmp/payment.zip &>$LOGS_FILE
VALIDATE $? "Removing existing code if any"

mkdir -p /app 

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading project into the temp"

cd /app 


unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping project"

 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing python dependencies"


cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service 
VALIDATE $? "Created payment service file"


systemctl daemon-reload &>>$LOGS_FILE
systemctl enable payment  &>>$LOGS_FILE
systemctl start payment  &>>$LOGS_FILE
VALIDATE $? "Started and enabled payment service"