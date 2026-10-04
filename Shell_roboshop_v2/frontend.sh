#!/bin/bash
app_name=payment
SCRIPT_DIR=$PWD
source ./common.sh
check_root

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

print_total_time