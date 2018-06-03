#!/bin/bash

MYSQL_ROOT_PASSWORD="$1"
MYSQL_WORDPRESS_PASSWORD="$1"

echo "grant all on *.* to 'root'@'localhost' identified by '${MYSQL_ROOT_PASSWORD}';"
echo "drop database if exists test;"
echo "use mysql;"
echo "delete from user where user = '';"
echo "create database wordpress;"
echo "grant all on *.* to 'wordpress'@'localhost' identified by '${MYSQL_WORDPRESS_PASSWORD}';"
echo "update user set host='${HOSTNAME}.${DOMAIN}' where user='root' and host='localhost.localdomain';"
echo "flush privileges;"
touch /usr/local/puppetbuild/locks/wordpressdb.lck
