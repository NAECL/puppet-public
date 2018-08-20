class mailhub::dovecot {

  group {'vmail':
    ensure => present,
    gid    => "$mailhub::params::mailgroup",
  } ->
  user { 'vmail':
    ensure  => 'present',
    comment => 'Mailbox User',
    home    => '/var/mail/vmail',
    gid     => 'vmail',
    uid     => "$mailhub::params::mailuser",
    shell   => '/bin/rbash',
  } ->
  file {'/var/mail/vmail':
    owner  => 'vmail',
    group  => 'vmail',
    ensure => directory,
  }

  file {'/etc/dovecot/passwd.db':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/mailhub/dovecot.passwd.db',
    notify  => Service['dovecot'],
  }

  file {'/etc/dovecot/conf.d/15-mailboxes.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/15-mailboxes.conf.erb'),
    notify  => Service['dovecot'],
  }

  file {'/etc/dovecot/conf.d/10-auth.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/10-auth.conf.erb'),
    notify  => Service['dovecot'],
  }

  file {'/etc/dovecot/conf.d/10-mail.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/10-mail.conf.erb'),
    notify  => Service['dovecot'],
  }

  file {'/etc/dovecot/conf.d/auth-system.conf.ext':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/auth-system.conf.ext.erb'),
    notify  => Service['dovecot'],
  }

  file {'/etc/dovecot/conf.d/99-mail-stack-delivery.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/99-mail-stack-delivery.conf.erb'),
    notify  => Service['dovecot'],
  }

  service {'dovecot':
    enable => true,
    ensure => running,
  }
}
