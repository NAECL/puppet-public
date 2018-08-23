class mailhub::postfix {

  file {'/etc/postfix/virtual-alias-maps':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/virtual-alias-maps.erb'),
    notify  => Exec['exec-update-virtual-alias-maps'],
  } ->

  file {'/etc/postfix/virtual-mailbox-maps':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/virtual-mailbox-maps.erb'),
    notify  => Exec['exec-update-mailbox-maps'],
  } ->

  file {'/etc/aliases':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/aliases.erb'),
    notify  => Exec['exec-update-aliases'],
  } ->

  file {'/etc/postfix/master.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/master.cf.erb'),
    notify  => Service['postfix'],
  } ->

  file {'/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailhub/main.cf.erb'),
    notify  => Service['postfix'],
  } ->

  service {'postfix':
    enable => true,
    ensure => running,
  }

  # These only get called when files are updated.
  exec { 'exec-update-aliases':
    command     => '/usr/bin/newaliases',
    cwd         => '/tmp',
    user        => 'root',
    group       => 'root',
    logoutput   => true,
    refreshonly => true,
    notify  => Service['postfix'],
  }

  exec { 'exec-update-virtual-alias-maps':
    command     => '/usr/sbin/postmap /etc/postfix/virtual-alias-maps',
    cwd         => '/tmp',
    user        => 'root',
    group       => 'root',
    logoutput   => true,
    refreshonly => true,
    notify  => Service['postfix'],
  }

  exec { 'exec-update-mailbox-maps':
    command     => '/usr/sbin/postmap /etc/postfix/virtual-mailbox-maps',
    cwd         => '/tmp',
    user        => 'root',
    group       => 'root',
    logoutput   => true,
    refreshonly => true,
    notify  => Service['postfix'],
  }
}
