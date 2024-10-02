class base::services (
  $firewall_enable = 'false',
  $firewall_state  = 'stopped',
) {
  if ( $::osfamily == 'redhat' ) {
    $cron_service = 'crond'

    if ( $::operatingsystemmajrelease == '6' ) {
      service { 'iptables':
        enable => $firewall_enable,
        ensure => $firewall_state,
      }
    }
  }

  if ( $::osfamily == 'Debian' ) {
    $cron_service = 'cron'
  }

  service {'vnstat':
    ensure => running,
    enable => true,
  }

  file {'/var/lib/vnstat/eth0':
    owner   => 'vnstat',
  }

  service {"${cron_service}":
    ensure => running,
    enable => true,
  }
}
