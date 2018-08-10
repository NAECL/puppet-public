#!/bin/bash -u

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin

# Set default installer, environment, and repositories these can be modified by a tag
#
DEFAULT_ANSIBLE_REPO=ansible
DEFAULT_PUPPET_REPO=puppet-public
DEFAULT_CHEF_REPO=chef
DEFAULT_ENVIRONMENT=production
DEFAULT_INSTALLER=puppet

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
repository=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Repository/ {print $2}')

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
        git clone https://github.com/NAECL/${repository}.git
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
    cd ${git_dir}
    git clone ssh://git-codecommit.eu-west-1.amazonaws.com/v1/repos/${repository}
    yum install http://aws.naecl.co.uk/public/build/dsl/chefdk-3.1.0-1.el7.x86_64.rpm
fi

if [ "${installer}" = "ansible" ]
then
    cd ${git_dir}
    git clone ssh://git-codecommit.eu-west-1.amazonaws.com/v1/repos/${ansible}
fi

init 6
