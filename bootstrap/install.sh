#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin
puppet_repo=puppet-public
default_env=production

sed -i '/ENVIRONMENT=/d' /etc/build_custom_config >/dev/null 2>&1
echo "ENVIRONMENT=${default_env}" >> /etc/build_custom_config

yum install -y redhat-lsb
distro=$(lsb_release -i | awk '{print $3}')
release=$(lsb_release -r | awk '{print $2}' | sed 's/\..*//')
yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm
if [ "${distro}" == "CentOS" -o "${distro}" == "RedHatEnterpriseServer" ]
then
    yum install -y https://yum.puppetlabs.com/puppet5/puppet-release-el-${release}.noarch.rpm
    yum install python-pip -y
    pip install awscli --upgrade
    puppet=/opt/puppetlabs/bin/puppet
    puppet_root=/etc/puppetlabs/puppet
    module_dir=${puppet_root}/code/environments/${default_env}/modules
fi

if [ "${distro}" == "AmazonAMI" ]
then
    puppet=/usr/bin/puppet
    puppet_root=/etc/puppet
    module_dir=${puppet_root}/environments/${default_env}/modules
fi

yum install -y git puppet

mkdir -p ${puppet_root}/hieradata ${puppet_root}/git ${module_dir}

if [ ! -L ${module_dir} ]
then
    rm -rf ${module_dir}
    ln -sf ${puppet_root}/git/${puppet_repo}/modules ${module_dir}
fi

instance=$(curl http://169.254.169.254/latest/meta-data/instance-id/ 2>/dev/null)
zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ 2>/dev/null)
region=$(echo ${zone} | sed 's/.$//')
role=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Role/ {print $2}')
environment=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Environment/ {print $2}')
hostname=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Name/ {print $2}')

# Set Hostname
sed -i '/^HOSTNAME=/d' /etc/build_custom_config >/dev/null 2>&1
echo "HOSTNAME=${hostname}" >> /etc/build_custom_config

if [ ! -d ${puppet_root}/git/${puppet_repo} ]
then
    cd ${puppet_root}/git
    git clone https://github.com/NAECL/${puppet_repo}.git
    ln -sf ${puppet_root}/git/${puppet_repo}/hiera/hiera.yaml ${puppet_root}/hiera.yaml
    ln -sf ${puppet_root}/git/${puppet_repo}/hiera/common.yaml ${puppet_root}/hieradata/common.yaml
    ln -sf ${puppet_root}/git/${puppet_repo}/hiera/${environment}.yaml ${puppet_root}/hieradata/environment.yaml
    ln -sf ${puppet_root}/git/${puppet_repo}/hiera/${hostname}.yaml ${puppet_root}/hieradata/hostname.yaml
else
    cd ${puppet_root}/git/${puppet_repo}
    git pull
fi

${puppet} apply --modulepath=${module_dir} -e "include base" 2>&1
/usr/local/bin/puppetBuildStandalone -r ${role}
init 6
