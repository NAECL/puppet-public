class rsyslog (
  $role = 'client',
) {
    service {'rsyslog':
      enable => true,
      ensure => running,
    }

    file {'/etc/rsyslog.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("rsyslog/rsyslog.${role}.conf.erb"),
      notify  => Service['rsyslog'],
    }
}
