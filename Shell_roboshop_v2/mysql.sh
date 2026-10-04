#!/bin/bash

app_name=payment
SCRIPT_DIR=$PWD
source ./common.sh
check_root

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Installing Mysql"

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld    &>>$LOGS_FILE
VALIDATE $? "Enabling and starting mySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
VALIDATE $? "Setting up root password for mysql"

print_total_time