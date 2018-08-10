#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin

# Set default installer and environment these can be modified by a tag
#
INSTALLER=puppet
ENVIRONMENT=production

# Install initial needed packages and tools
#
yum install -y redhat-lsb
distro=$(lsb_release -i | awk '{print $3}')
release=$(lsb_release -r | awk '{print $2}' | sed 's/\..*//')
yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm

if [ "${distro}" == "CentOS" -o "${distro}" == "RedHatEnterpriseServer" ]
then
    yum install python-pip -y
    pip install awscli --upgrade
fi

# Now interrogate the tags and metadata to find ot about this ami
#
instance=$(curl http://169.254.169.254/latest/meta-data/instance-id/ 2>/dev/null)
zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ 2>/dev/null)
region=$(echo ${zone} | sed 's/.$//')
role=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Role/ {print $2}')
environment=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Environment/ {print $2}')
hostname=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Name/ {print $2}')
installer=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Installer/ {print $2}')

# If installer isn't specified, use default
#
if [ "${installer}" = "" ]
then
    installer=${INSTALLER}
fi

# If environment isn't specified, use default
#
if [ "${environment}" = "" ]
then
    environment=${ENVIRONMENT}
fi

# Prepare GIT
git_dir=/etc/git
yum install -y git
mkdir -p ${git_dir}


# Now do installer mechanism specific stuff
#
if [ "${installer}" = "puppet" ]
then
    puppet_repo=puppet-public

    # Set Hostname and Environment for later use by custom facts
    #
    sed -i '/^HOSTNAME=/d' /etc/build_custom_config >/dev/null 2>&1
    echo "HOSTNAME=${hostname}" >> /etc/build_custom_config
    sed -i '/ENVIRONMENT=/d' /etc/build_custom_config >/dev/null 2>&1
    echo "ENVIRONMENT=${environment}" >> /etc/build_custom_config

    if [ "${distro}" == "CentOS" -o "${distro}" == "RedHatEnterpriseServer" ]
    then
        yum install -y https://yum.puppetlabs.com/puppet5/puppet-release-el-${release}.noarch.rpm
        puppet=/opt/puppetlabs/bin/puppet
        puppet_root=/etc/puppetlabs/puppet
        module_dir=${puppet_root}/code/environments/${environment}/modules
    fi

    if [ "${distro}" == "AmazonAMI" ]
    then
        puppet=/usr/bin/puppet
        puppet_root=/etc/puppet
        module_dir=${puppet_root}/environments/${environment}/modules
    fi

    yum install -y puppet

    mkdir -p ${module_dir}

    if [ ! -L ${module_dir} ]
    then
        rm -rf ${module_dir}
        ln -sf ${git_dir}/${puppet_repo}/modules ${module_dir}
    fi

    if [ ! -d ${git_dir}/${puppet_repo} ]
    then
        cd ${git_dir}
        git clone https://github.com/NAECL/${puppet_repo}.git
        ln -sf ${git_dir}/${puppet_repo}/hiera/hiera.yaml ${puppet_root}/hiera.yaml
        ln -sf ${git_dir}/${puppet_repo}/hiera/common.yaml ${puppet_root}/hieradata/common.yaml
        ln -sf ${git_dir}/${puppet_repo}/hiera/${environment}.yaml ${puppet_root}/hieradata/environment.yaml
        ln -sf ${git_dir}/${puppet_repo}/hiera/${hostname}.yaml ${puppet_root}/hieradata/hostname.yaml
    else
        cd ${git_dir}/${puppet_repo}
        git pull
    fi

    ${puppet} apply --modulepath=${module_dir} -e "include base" 2>&1
    /usr/local/bin/puppetBuildStandalone -r ${role}
fi

if [ "${installer}" = "chef" ]
then
    yum install http://aws.naecl.co.uk/public/build/dsl/chefdk-3.1.0-1.el7.x86_64.rpm
fi

init 6
