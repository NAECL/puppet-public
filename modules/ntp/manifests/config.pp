class ntp::config {

  File {
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Class['ntp::install'],
    notify  => Class['ntp::service']
  }

  file { '/etc/ntp.conf':
    ensure  => present,
    content => template('ntp/ntp.conf.erb'),
  }

  if ( $::operatingsystem == 'CentOS' ) {
    file { '/etc/ntp/step-tickers':
      ensure  => present,
      content => template('ntp/step-tickers.erb')
    }
  }
}
