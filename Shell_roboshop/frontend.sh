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


dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

rm -rf /usr/share/nginx/html/* &>$LOGS_FILE
VALIDATE $? "Removing existing html directory"

rm -rf  /tmp/frontend.zip &>$LOGS_FILE
VALIDATE $? "Removing existing code if any"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading project into the temp"

cd /usr/share/nginx/html 

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping project"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf 
VALIDATE $? "Created nginx config file"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx &>>$LOGS_FILE
systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Started and enabled frontend service"