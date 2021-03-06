class chef::master (
  $version   = '12.17.33-1',
) {
    if ( $::osfamily == 'redhat' ) {
        $osver = $::operatingsystemmajrelease
        $chef_rpm = "chef-server-core-${version}.el${osver}.x86_64.rpm"

        exec {'download-chef-rpm':
            command => "/usr/bin/wget http://aws.naecl.co.uk/public/build/dsl/${chef_rpm}",
            creates => "/usr/local/buildfiles/${chef_rpm}",
            cwd     => '/usr/local/buildfiles',
        } ->

        file {"/usr/local/buildfiles/${chef_rpm}":
            owner => 'root',
        } ->

        exec {'install_chef_rpm':
            command => "/usr/bin/yum install -y /usr/local/buildfiles/${chef_rpm}",
            creates => '/opt/opscode/embedded/cookbooks',
        } ->

        file {'/etc/chef_install.cfg':
            owner   => 'root',
            group   => 'root',
            mode    => '0640',
            content => template('chef/chef_install.cfg.erb')
        } ->

        file {'/usr/local/buildfiles/chef_install.sh':
            owner  => 'root',
            group  => 'root',
            mode   => '0750',
            source => 'puppet:///modules/chef/chef_install.sh',
        } ->

        exec {'chef_install':
            command => '/usr/local/buildfiles/chef_install.sh',
            creates => '/usr/local/puppetbuild/locks/chef_install.lck',
            timeout => '0',
        }
    }
}
