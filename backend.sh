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

dnf module disable nodejs -y &>> $LOG
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>> $LOG
VALIDATE $? "enable nodejs is"

dnf install nodejs -y &>> $LOG
VALIDATE $? "nodejs install is"

id expense &>> $LOG
if [ $? -ne 0 ]
then
    useradd expense &>> $LOG
    VALIDATE $? "user created" &>> $LOG
else
    echo -e "user is already there.. $Y skipping $N" &>> $LOG
 fi

mkdir -p /app &>> $LOG
VALIDATE $? "dir creation is"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG
VALIDATE $? "download code is"

unzip /tmp/backend.zip &>> $LOG
VALIDATE $? "unzip code is"

cd /app
rm -rf /app/* &>> $LOG
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
VALIDATE $? "installed mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "schema loaded"

systemctl restart backend
VALIDATE $? "backend restarted"