#/bin/bash
x=0
msg="*** Environment variables"
if [ -z "$MYSQL_USER" ]; then
       msg="$msg MYSQL_USER"
       x=1
fi
if [ -z "$MYSQL_PASSWORD" ]; then
       	msg="$msg MYSQL_PASSWORD"
	x=1
fi
if [ -z "$MYSQL_DATABASE" ]; then
       	msg="$msg MYSQL_DATABASE"
	x=1
fi
if [ $x -eq 1 ]; then
	msg="$msg not set."
	echo "$msg"
	exit 1
fi
service mysql start
sleep 30
mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
sleep 5
mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
sleep 5
mysql -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
sleep 5
mysql -e "FLUSH PRIVILEGES;"
sleep 5
echo "MYSQL USER     : $MYSQL_USER"
echo "MYSQL DATABASE  : $MYSQL_DATABASE"
service mysql restart
tail -f /var/log/mysql/error.log
