class squid::config (
  $localnet = undef,
) {
  file {'/etc/squid/squid.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'squid',
    mode    => '0640',
    content => template('squid/squid.conf.erb'),
    notify  => Service['squid'],
  } ->

  service {'squid':
    enable => true,
    ensure => running,
  }
}
