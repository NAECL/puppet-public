class firewalld::config (
  $extra_services = undef,
) {
  $role         = $firewalld::role
  $base_services = ['nrpe']
  $web_services = ['http', 'https']

  if ( $role == 'apache' ) {
    $fw_services = $base_services + $web_services
  } elsif ( $role == 'bamboo' ) {
    $fw_services = $base_services + $web_services
  } elsif ( $role == 'chef' ) {
    $fw_services = $base_services + $web_services
  } elsif ( $role == 'nagios' ) {
    $fw_services = $base_services + $web_services
  } elsif ( $role == 'gitlab' ) {
    $fw_services = $base_services + $web_services
  } elsif ( $role == 'jenkins' ) {
    $fw_services = $base_services + $web_services + ['jenkins']
  } elsif ( $role == 'katello' ) {
    $fw_services = $base_services + $web_services + ['katello', 'puppetmaster']
  } elsif ( $role == 'wordpress' ) {
    $fw_services = $base_services + $web_services
  } else {
    $fw_services = $base_services
  }

  if ( $extra_services != undef ) {
    $services = $fw_services + $extra_services
  } else {
    $services = $fw_services
  }

  case $operatingsystemmajrelease {
    '7': {
      file {'/etc/firewalld/zones/public.xml':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['firewalld.service'],
        content => template("firewalld/public.xml.erb"),
      }
 
      firewalld::createServiceFiles {[ 'jenkins.xml', 'puppetmaster.xml', 'katello.xml', ]: }

      service {'firewalld.service':
        ensure => running,
        enable => true,
      }
    }
    '6': {
      file {'/etc/sysconfig/iptables':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        notify  => Service['iptables'],
        source  => "puppet:///modules/firewalld/iptables.$role",
      }
 
      service {'iptables':
        ensure => running,
        enable => true,
      }
    }
  }
}
