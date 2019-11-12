class squid::config {
  file {'/etc/squid/squid.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('squid/squid.conf.erb'),
  }
}
