#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling default node js version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling node js version 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing node js version 20"

##CHecking whether user is already created
id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user with no login"
else
    echo -e "$Y [INFO] User already created....SKIPPINGGG $N"
fi

rm -rf /app &>$LOGS_FILE
VALIDATE $? "Removing existing app directory"

rm -rf  /tmp/catalogue.zip &>$LOGS_FILE
VALIDATE $? "Removing existing code if any"

mkdir -p /app 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading project into the temp"

cd /app 


unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping project"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing node packages"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Created catalogue service file"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE  $? "Created mongo repo"


dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installing mongodb client"

INDEX=$(mongosh --host mongodb.adityabuilds.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.adityabuilds.fun </app/db/master-data.js &>>$LOGS_FILE
else
    echo -e "$Y [INFO] $N products already loaded"
fi

systemctl enable catalogue &>>$LOGS_FILE
systemctl start catalogue &>>$LOGS_FILE
VALIDATE $? "Enabling and starting catalogue service"
