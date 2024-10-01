#!/bin/bash
USER=$(id -u)
TIME=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0|cut -d "." -f1)
LOG=/tmp/$SCRIPTNAME-$TIME.log
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"

if [ $USER -ne 0 ]
then
    echo "Please run this script with root access"
    exit 1 #manually exit if error comes.
else
    echo "You are super user"
fi

VALIDATE (){
if [ $1 -ne 0 ]
then
    echo -e "$2...  $R failure $N"
#    exit 1
else
    echo -e "$2... $G success $N"
fi
}

dnf install nginx -y &>> $LOG
VALIDATE $? "Installing ngins is"

systemctl enable nginx &>> $LOG
VALIDATE $? "Enabling nginx is"

systemctl start nginx &>> $LOG
VALIDATE $? "Starting nginx is"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG
VALIDATE $? "Dowloading frontend code is"

cd /usr/share/nginx/html
rm -rf /usr/share/nginx/html/*
unzip /tmp/frontend.zip &>> $LOG
VALIDATE $? "Downloading frontend code is"

cp /home/ec2-user/Expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>> $LOG
VALIDATE $? "copied conf file is"

systemctl restart nginx &>> $LOG
VALIDATE $? "Restaring nginx is"