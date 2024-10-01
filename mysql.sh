#!/bin/bash
USER=$(id -u)
TIME=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0|cut -d "." -f1)
LOG=/tmp/$SCRIPTNAME-$TIME.log
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"
echo "Enter the db root password"
read -s mysql_root_password

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

dnf install mysql-server -y &>> $LOG
VALIDATE $? "The mysql installation is"

systemctl enable mysqld &>> $LOG
VALIDATE $? "Enabled mysqld is"

systemctl start mysqld &>> $LOG
VALIDATE $? "mysql start is"

##checking mysql root password setup
mysql -h db.devopslearning2025.online -uroot -p${mysql_root_password} -e 'SHOW DATABSES;' &>>LOG

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>> $LOG
    VALIDATE $? "root password setting is"
else
    echo -e "mysql password already setup $Y SKIPPING... $N"
fi