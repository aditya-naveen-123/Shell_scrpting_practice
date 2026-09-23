#!/bin/bash
LOGS_FILE_NAME=$0
USER_ID=$(id -u)
LOGS_FILE="/var/log/shell-script/$LOGS_FILE_NAME.log"

if [ $USER_ID -ne 0 ]; then 
    echo "USer do not have permissions to run this script: Please run with sudo access"
    exit 1
fi

VALIDATE() {
    if [ $2 -ne 0 ]; then
        echo "Installing $1 is failed"
    else
        echo "Installing the package $1 is success"
    fi
}

dnf list installed mysql &>>$LOGS_FILE

if [ $? -eq 0 ]; then
    echo "Required package mysql is already installed skipping"
    exit 1
else 
    echo "Installing My SQL....."
    dnf install mysql &>>$LOGS_FILE

fi
VALIDATE mysql $?