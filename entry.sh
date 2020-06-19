#!/bin/sh

# configuring timezone
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime 
echo "${TIMEZONE}" > /etc/timezone 

# start apache
echo "Starting httpd"
httpd
echo "Done httpd"


# check if mysql data directory is nuked
# if so, install the db
echo "Checking /var/lib/mysql folder"
if [ ! -f /var/lib/mysql/ibdata1 ]; then 
    echo "Installing db"
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql > /dev/null
    echo "Installed"
fi;

tfile=/tmp/dbinit.sql
touch $tfile
if [ ! -f "$tfile" ]; then
    return 1
fi

cat << EOF > $tfile
    DROP DATABASE IF EXISTS test;
    USE mysql;
    DELETE FROM user WHERE user='';
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWD}';
    ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWD}';
    GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
    FLUSH PRIVILEGES;
EOF

if [ ! -d /var/lib/mysql/ttrss ]; then
    echo "" >> $tfile
    echo "" >> $tfile
    echo "USE ${DB_NAME}" >> $tfile
    echo "" >> $tfile
    cat /var/www/localhost/htdocs/schema/ttrss_schema_mysql.sql >> $tfile
fi;


echo "Querying user"
/usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
echo "Done query"

echo "Configuring tt-rss"
cp /var/www/localhost/htdocs/config.php-dist /var/www/localhost/htdocs/config.php
sed -i "s#%DB_TYPE#mysql#" /var/www/localhost/htdocs/config.php
sed -i "s#%DB_USER#${DB_USER}#" /var/www/localhost/htdocs/config.php
sed -i "s#%DB_NAME#${DB_NAME}#" /var/www/localhost/htdocs/config.php
sed -i "s#%DB_PASS#${DB_PASSWD}#" /var/www/localhost/htdocs/config.php
sed -i "s#%DB_HOST#localhost#" /var/www/localhost/htdocs/config.php
sed -i "s#%DB_PORT#3306#" /var/www/localhost/htdocs/config.php
sed -i "s#%SELF_URL_PATH#${SELF_URL_PATH}#" /var/www/localhost/htdocs/config.php

echo "Executing crond"
crond -b

echo "Update TinyTinyRSS : git pull" 
git pull

# start mysql
# nohup mysqld_safe --skip-grant-tables --bind-address 0.0.0.0 --user mysql > /dev/null 2>&1 &
echo "Starting mariadb database"
exec /usr/bin/mysqld --user=root --init-file=$tfile

