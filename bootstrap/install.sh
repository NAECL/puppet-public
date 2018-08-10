#!/bin/bash -ux

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin

# Set default installer, environment, and repositories these can be modified by a tag
#
DEFAULT_ANSIBLE_REPO=${ANSIBLE_REPO:=ansible-public}
DEFAULT_PUPPET_REPO=${PUPPET_REPO:=puppet-public}
DEFAULT_CHEF_REPO=${CHEF_REPO:=chef-public}
DEFAULT_ENVIRONMENT=${ENVIRONMENT:=production}
DEFAULT_INSTALLER=${INSTALLER:=puppet}
DEFAULT_GIT_URL=${GIT_URL:=https://github.com/NAECL}
DEFAULT_GIT_SUFFIX=${GIT_SUFFIX:=.git}
AWS_INSTALL=${AWS_INSTALL:=true}
REBOOT=${REBOOT:=true}

# Install initial needed packages and tools
#
yum install -y redhat-lsb
distro=$(lsb_release -i | awk '{print $3}')
release=$(lsb_release -r | awk '{print $2}' | sed 's/\..*//')
yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm

# Now interrogate the tags and metadata to find ot about this ami
#
if [ "${AWS_INSTALL}" = "true" ]
then
    if [ "${distro}" == "CentOS" -o "${distro}" == "RedHatEnterpriseServer" ]
    then
        yum install python-pip -y
        pip install awscli --upgrade
    fi

    instance=$(curl http://169.254.169.254/latest/meta-data/instance-id/ 2>/dev/null)
    zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ 2>/dev/null)
    region=$(echo ${zone} | sed 's/.$//')

    role=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Role/ {print $2}')

    environment=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Environment/ {print $2}')

    hostname=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Name/ {print $2}')

    installer=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Installer/ {print $2}')

    repository=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Repository/ {print $2}')

    git_url=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Git_Url/ {print $2}')

    git_suffix=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Git_Suffix/ {print $2}')
else
    role=${ROLE:=base}
    hostname=${HOSTNAME:=hostname}
    environment=""
    installer=""
    repository=""
    git_url=""
    git_suffix=""
fi

# If installer isn't specified, use default
#
if [ "${installer}" = "" ]
then
    installer=${DEFAULT_INSTALLER}
fi

# If environment isn't specified, use default
#
if [ "${environment}" = "" ]
then
    environment=${DEFAULT_ENVIRONMENT}
fi

# If git_url isn't specified, use default
#
if [ "${git_url}" = "" ]
then
    git_url=${DEFAULT_GIT_URL}
fi

# If git_suffix isn't specified, use default
#
if [ "${git_suffix}" = "" ]
then
    # Naff workaround to exporting an empty class
    #
    if [ "${DEFAULT_GIT_SUFFIX}" = "null" ]
    then
        git_suffix=""
    else
        git_suffix=${DEFAULT_GIT_SUFFIX}
    fi
fi

case ${installer} in
    puppet)     REPOSITORY=${DEFAULT_PUPPET_REPO}
                ;;
    chef)       REPOSITORY=${DEFAULT_CHEF_REPO}
                ;;
    ansible)    REPOSITORY=${DEFAULT_ANSIBLE_REPO}
                ;;
    *)          echo "Error Invalid Installer Specified"
                exit 1
                ;;
esac

# If repository isn't specified, use default
#
if [ "${repository}" = "" ]
then
    repository=${REPOSITORY}
fi

# Prepare git
git_dir=/etc/git
yum install -y git
mkdir -p ${git_dir}

# Now do installer mechanism specific stuff
#
if [ "${installer}" = "puppet" ]
then

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
        ln -sf ${git_dir}/${repository}/modules ${module_dir}
    fi

    if [ ! -d ${git_dir}/${repository} ]
    then
        cd ${git_dir}
        git clone ${git_url}/${repository}${git_suffix}
        ln -sf ${git_dir}/${repository}/hiera/hiera.yaml ${puppet_root}/hiera.yaml
        ln -sf ${git_dir}/${repository}/hiera/common.yaml ${puppet_root}/hieradata/common.yaml
        ln -sf ${git_dir}/${repository}/hiera/${environment}.yaml ${puppet_root}/hieradata/environment.yaml
        ln -sf ${git_dir}/${repository}/hiera/${hostname}.yaml ${puppet_root}/hieradata/hostname.yaml
    else
        cd ${git_dir}/${repository}
        git pull
    fi

    ${puppet} apply --modulepath=${module_dir} -e "include base" 2>&1
    /usr/local/bin/puppetBuildStandalone -r ${role}
fi

if [ "${installer}" = "chef" ]
then
    if [ ! -d ${git_dir}/${repository} ]
    then
        cd ${git_dir}
        git clone ${git_url}/${repository}${git_suffix}
        yum install -y http://aws.naecl.co.uk/public/build/dsl/chefdk-3.1.0-1.el7.x86_64.rpm
    else
        cd ${git_dir}/${repository}
        git pull
    fi
fi

if [ "${installer}" = "ansible" ]
then
    if [ ! -d ${git_dir}/${repository} ]
    then
        cd ${git_dir}
        git clone ${git_url}/${repository}${git_suffix}
    else
        cd ${git_dir}/${repository}
        git pull
    fi
fi

if [ "${REBOOT}" = "true" ]
then
    init 6
fi
