#!/bin/bash

cp -r /usr/share/wordpress/ /var/www/$1
chown -R apache:apache /var/www/$1
echo $1 > /usr/local/puppetbuild/locks/$1.webcreated.lck
