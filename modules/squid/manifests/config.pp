class squid::config (
  $localnet = undef,
  $userpass = undef,
) {
  file {'/etc/squid/passwords':
    ensure  => present,
    owner   => 'root',
    group   => 'proxy',
    mode    => '0640',
    content => template('squid/squid.password.erb'),
    notify  => Service['squid'],
  } ->

  file {'/etc/squid/squid.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'proxy',
    mode    => '0640',
    content => template('squid/squid.conf.erb'),
    notify  => Service['squid'],
  } ->

  service {'squid':
    enable => true,
    ensure => running,
  }
}
