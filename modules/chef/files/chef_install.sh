#!/bin/bash -x

# This is just a rough and ready list of commands to get things started. Not putting too much effort
# Into creating a puppet build for a chef server, doesn't make much sense
# Based on https://docs.chef.io/install_server.html
#
/bin/chef-server-ctl reconfigure
if [ $? -ne 0 ]
then
	exit 1
fi
/bin/chef-server-ctl user-create isalt Ian Salt chef@naecl.com 'PASSWORD' --filename FILE_NAME
if [ $? -ne 0 ]
then
	exit 1
fi
/bin/chef-server-ctl org-create short_name 'naecl' --association_user isalt --filename ORGANIZATION-validator.pem
if [ $? -ne 0 ]
then
	exit 1
fi
/bin/chef-server-ctl install chef-manage
if [ $? -ne 0 ]
then
	exit 1
fi
/bin/chef-server-ctl reconfigure
if [ $? -ne 0 ]
then
	exit 1
fi
/bin/chef-manage-ctl reconfigure --accept-license
if [ $? -ne 0 ]
then
	exit 1
fi

touch /usr/local/puppetbuild/locks/chef_install.lck