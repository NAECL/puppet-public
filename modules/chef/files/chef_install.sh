#!/bin/bash -xu

export PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

exec > /var/log/chef_install.log 2>&1

. /etc/chef_install.cfg

# This is just a rough and ready list of commands to get things started. Not putting too much effort
# Into creating a puppet build for a chef server, doesn't make much sense
# Based on https://docs.chef.io/install_server.html
#
chef-server-ctl reconfigure
if [ $? -ne 0 ]
then
	exit 1
fi
chef-server-ctl user-create ${username} ${firstname} ${lastname} ${email} ${password} --filename FILE_NAME
if [ $? -ne 0 ]
then
	exit 1
fi
chef-server-ctl org-create ${orgshortname} ${orglongname} --association_user ${username} --filename ORGANIZATION-validator.pem
if [ $? -ne 0 ]
then
	exit 1
fi
chef-server-ctl install chef-manage
if [ $? -ne 0 ]
then
	exit 1
fi
chef-server-ctl reconfigure
if [ $? -ne 0 ]
then
	exit 1
fi
chef-manage-ctl reconfigure --accept-license
if [ $? -ne 0 ]
then
	exit 1
fi

touch /usr/local/puppetbuild/locks/chef_install.lck
