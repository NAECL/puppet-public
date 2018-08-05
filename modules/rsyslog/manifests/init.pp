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

    file {"/etc/pki/rsyslog/${servername}-cert.pem":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
      source => "puppet:///modules/rsyslog/${servername}-cert.pem",
    } ->

    file {"/etc/pki/rsyslog/${servername}-key.pem":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
      source => "puppet:///modules/rsyslog/${servername}-key.pem",
    } ->

    file {'/etc/rsyslog.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("rsyslog/rsyslog.${role}.conf.erb"),
      notify  => Service['rsyslog'],
    }
}
