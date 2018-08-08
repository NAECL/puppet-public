class rsyslog (
  $role      = 'client',
  $collector = 'localhost',
) {
    $servername = $base::servername

    service {'rsyslog':
      enable => true,
      ensure => running,
    }

    package {'rsyslog-gnutls':
      ensure => present,
    } ->

    file {'/etc/pki/rsyslog':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    } ->

    file {'/etc/pki/rsyslog/ca.pem':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
      source => 'puppet:///modules/rsyslog/ca.pem',
    } ->

    file {'/etc/rsyslog.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('rsyslog/rsyslog.conf.erb'),
      notify  => Service['rsyslog'],
    }

    if ( $role == 'client' ) {
        file {'/etc/pki/rsyslog/sender-cert.pem':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0640',
        notify => Service['rsyslog'],
        source => [ 'puppet:///modules/rsyslog/sender-cert.pem' ]
        }

        file {'/etc/pki/rsyslog/sender-key.pem':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0640',
        notify => Service['rsyslog'],
        source => [ 'puppet:///modules/rsyslog/sender-key.pem' ]
        }
    } else {
        file {'/etc/pki/rsyslog/collector-cert.pem':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0640',
        notify => Service['rsyslog'],
        source => [ 'puppet:///modules/rsyslog/collector-cert.pem' ]
        }

        file {'/etc/pki/rsyslog/collector-key.pem':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0640',
        notify => Service['rsyslog'],
        source => [ 'puppet:///modules/rsyslog/collector-key.pem' ]
        }
    }
}
