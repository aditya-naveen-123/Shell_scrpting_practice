#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

sudo mkdir -p $LOGS_FOLDER
sudo chown ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"

USER_ID=$(id -u)

echo -e "$Y [INFO] ....Script execution started $N"
check_root() {
    if [ $USER_ID -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $RPlease run this script with root access $N" | tee -a $LOGS_FILE
        exit 1
    fi

}


VALIDATE() {

    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP $R [ERROR] $2 FAILED $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP $G [INFO] $2 SUCCESS.. $N" | tee -a $LOGS_FILE
    fi

}


print_total_time() {
    echo -e "$G [INFO] ..... Script executed in $SECONDS sconds.. $N"
}


app_setup() {
        id roboshop &>>$LOGS_FILE
        if [ $? -ne 0 ]; then
            useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
            VALIDATE $? "Creating system user with no login"
        else
            echo -e "$Y [INFO] User already created....SKIPPINGGG $N"
        fi

        rm -rf /app &>$LOGS_FILE
        VALIDATE $? "Removing existing app directory"

        rm -rf  /tmp/$app_name.zip &>$LOGS_FILE
        VALIDATE $? "Removing existing code if any"

        mkdir -p /app 

        curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
        VALIDATE $? "Downloading project into the temp"

        cd /app 


        unzip /tmp/$app_name.zip &>>$LOGS_FILE
        VALIDATE $? "Unzipping project"
}

nodejs_setup() {
        dnf module disable nodejs -y &>>$LOGS_FILE
        VALIDATE $? "Disabling default node js version"

        dnf module enable nodejs:20 -y &>>$LOGS_FILE
        VALIDATE $? "Enabling node js version 20"

        dnf install nodejs -y &>>$LOGS_FILE
        VALIDATE $? "Installing node js version 20"

        npm install &>>$LOGS_FILE
        VALIDATE $? "Installing node packages"
}

systemd_setup() {
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service 
    VALIDATE $? "Created $app_name service file"
    systemctl daemon-reload
    systemctl enable $app_name
    VALIDATE $? "Enabled $app_name"

}

app_restart() {
    systemctl enable $app_name &>>$LOGS_FILE
    systemctl start $app_name &>>$LOGS_FILE
    VALIDATE $? "Enabling and starting $app_name service"
}

java_setup() {
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing maven"
    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Cleaning maven package"

    mv target/shipping-1.0.jar shipping.jar &>> $LOGS_FILE
    VALIDATE $? "Moving shipping jar file"

}

python_setup() {
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Installing Python"
    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Installing python dependencies"
}