USER=$(id -u)
TIME=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0|cut -d "." -f1)
LOG=/tmp/$SCRIPTNAME-$TIME.log
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"
echo "Enter the mysql root paswword"
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

dnf module disable nodejs -y &>> $LOG
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>> $LOG
VALIDATE $? "Enabling nodejs:20 version is"

dnf install nodejs -y &>> $LOG
VALIDATE $? "Installing nodejs is"

id expense &>> $LOG
if [ $? -ne 0 ]
then
    useradd expense &>> $LOG
    VALIDATE $? "Creating expense user is" &>> $LOG
else
    echo -e "user is already there.. $Y skipping $N"
 fi

mkdir -p /app &>> $LOG
VALIDATE $? "Creating app directory is"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG
VALIDATE $? "downloading backend code is"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>> $LOG
VALIDATE $? "unzip backend code is"

npm install &>> $LOG
VALIDATE $? "npm dependies install is"

cp /home/ec2-user/Expense-shell/backend.service /etc/systemd/system/backend.service  &>>$LOG
VALIDATE $? "copied backend.servce"

systemctl daemon-reload  &>>$LOG
VALIDATE $? "daemon reload is"

systemctl start backend  &>>$LOG
VALIDATE $? "backend started"

systemctl enable backend  &>>$LOG
VALIDATE $? "backend enabled"

dnf install mysql -y &>>$LOG
VALIDATE $? "installed mysql client is"

mysql -h db.devopslerning2025.online -uroot -p${mysql_root_password} < /app/schema/backend.sql  &>>$LOG
VALIDATE $? "schema loading is"

systemctl restart backend  &>>$LOG
VALIDATE $? "backend restart is"