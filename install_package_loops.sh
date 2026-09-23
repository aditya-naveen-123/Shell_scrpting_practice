#!/bin/bash
LOGS_FILE_NAME=$0
USER_ID=$(id -u)
LOGS_FILE="/var/log/shell-script/$LOGS_FILE_NAME.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then 
    echo -e "$TIMESTAMP $Y [INFO] : $N USer do not have permissions to run this script: Please run with sudo access" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE() {
    if [ $2 -ne 0 ]; then
        echo -e "$TIMESTAMP $R [ERROR] :  Installing $1 is failed" | tee -a $LOGS_FILE
    else
        echo -e "$TIMESTAMP $G [INFO] : Installing the package $1 is success" | tee -a $LOGS_FILE
    fi
}

for package in $@
    do
        dnf list installed $package
        if [ $? -eq 0 ]; then
            echo -e "$TIMESTAMP $Y [INFO]: $N Required $package is already installed skipping" | tee -a $LOGS_FILE
            #exit 1
        else 
            echo -e "$TIMESTAMP $Y [INFO] Installing $package....." | tee -a $LOGS_FILE
            dnf install $package -y &>>$LOGS_FILE
             VALIDATE $package $?
        fi
       
    done
