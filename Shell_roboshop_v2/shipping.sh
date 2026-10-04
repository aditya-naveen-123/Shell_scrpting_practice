#!/bin/bash
app_name=shipping
SCRIPT_DIR=$PWD
source ./common.sh

check_root
app_setup
java_setup
systemd_setup


dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing mysql to load data"

mysql -h mysql.adityabuilds.fun -u root -pRoboShop@1 -e "use cities" &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $SQL_DOMAIN -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $SQL_DOMAIN -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $SQL_DOMAIN -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Data loaded into SQL"
else
    echo -e "$Y [INFO] Data already loaded into mysql $N"
fi
app_restart
print_total_time