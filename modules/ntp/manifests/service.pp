class ntp::service {
  if ( $::operatingsystem == 'Ubuntu' ) {
    $service = 'ntp'
  } else {
    $service = 'ntpd'
  }
  service { "$service":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Class['ntp::install'],
    subscribe  => Class['ntp::config']
  }
}
