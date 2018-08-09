class chef::install (
  $version = '12.17.33-1',
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

        exec {'install-chef':
            command => "/usr/bin/yum install -y /usr/local/buildfiles/${chef_rpm}",
            creates => '/opt/opscode/embedded/cookbooks',
        }
    }
}
