This is the file distributed by default if no specific Nagios Scripts are required for the role being built.

If specific scripts are required, place them in modules/nrpe/files/role_specific/libexec/${role}/ in the
Puppet manifest.

Don't forget to specify the scripts in the modules/nrpe/files/role_specific/configs/nrpe.${role}.cfg file
