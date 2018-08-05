class rsyslog (
  $role      = 'client',
  $collector = 'localhost',
) {
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

    file {'/etc/pki/rsyslog/collector-cert.pem':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
      source => 'puppet:///modules/rsyslog/collector-cert.pem',
    } ->

    file {'/etc/pki/rsyslog/collector-key.pem':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
      source => 'puppet:///modules/rsyslog/collector-key.pem',
    } ->

    file {'/etc/rsyslog.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("rsyslog/rsyslog.${role}.conf.erb"),
      notify  => Service['rsyslog'],
    }
}
