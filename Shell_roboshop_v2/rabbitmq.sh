#!/bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Cpoying rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Installing Rabbit MQ server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
systemctl start rabbitmq-server &>>$LOGS_FILE

VALIDATE $? "Starting and Enabling rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
VALIDATE $? "Adding roboshopuer"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "Setting up rabbit mq permissions"

print_total_time