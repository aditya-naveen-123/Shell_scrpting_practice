#!/bin/bash
app_name=catalogue
SCRIPT_DIR=$PWD
source ./common.sh
check_root
app_setup
nodejs_setup
systemd_setup

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

app_restart
print_total_time