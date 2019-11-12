class squid::config {
  file {'/etc/squid/squid.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'squid',
    mode    => '0640',
    content => template('squid/squid.conf.erb'),
  }
}
