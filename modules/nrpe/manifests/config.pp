class nrpe::config (
  $role,
) {

  group {'nagios':
    ensure => present,
    system => true,
  } ->
  user {'nagios':
    ensure => present,
    gid    => nagios,
    system => true,
  }

  file {'/etc/sudoers.d/nrpe':
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    content => "# User rules for nrpe\nnrpe ALL=(ALL) NOPASSWD:/usr/local/nagios/libexec/sudoScripts/\n",
  }

  file {'/usr/local/nagios':
    ensure => directory,
    owner  => 'nagios',
    group  => 'nrpe',
  } ->
  file { '/usr/local/nagios/locks':
    ensure => directory,
    owner  => 'nagios',
    group  => 'nrpe',
    mode   => '0770',
  } ->
  file {'/usr/local/nagios/etc':
    ensure => directory,
    owner  => 'nagios',
    group  => 'nrpe',
    mode   => '0750',
  } ->
  file {'/usr/local/nagios/libexec':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nrpe',
    mode    => '0750',
    recurse => true,
  } ->
  file {'/usr/local/nagios/libexec/sudoScripts':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nrpe',
    mode    => '0750',
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/nrpe/sudoScripts',
  } ->
  file {'/usr/local/nagios/libexec/sudoScripts/service':
    ensure => link,
    target => '/sbin/service',
  } ->
  file {'/usr/local/nagios/libexec/custom':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nrpe',
    mode    => '0750',
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/nrpe/custom',
  } ->
  file {'/usr/local/nagios/libexec/custom/utils.sh':
    ensure  => present,
    owner   => 'nagios',
    group   => 'nrpe',
    mode    => '0750',
    content => template('nrpe/utils.sh.erb'),
  } ->
  file {'/etc/nagios':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nrpe',
    mode    => '0755',
    require => Class['nrpe::packages'],
  } ->
  file {'/etc/nrpe.d':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nrpe',
    notify  => Service['nrpe'],
    mode    => '0750',
    recurse => true,
    purge   => true,
  } ->
  file {'/etc/nrpe.d/nrpe.common.cfg':
    ensure => present,
    owner  => 'nagios',
    group  => 'nrpe',
    mode   => '0640',
    source => 'puppet:///modules/nrpe/nrpe.common.cfg',
    notify => Service['nrpe'],
  } ->
  file {"/etc/nrpe.d/nrpe.${role}.cfg":
    ensure  => present,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0640',
    notify  => Service['nrpe'],
    source  => [
                 "puppet:///modules/nrpe/role_specific/configs/nrpe.${role}.cfg",
                 "puppet:///modules/nrpe/role_specific/configs/nrpe.default.cfg",
               ],
  }
  file {"/usr/local/nagios/libexec/custom/${role}":
    ensure  => present,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0750',
    purge   => true,
    recurse => true,
    force   => true,
    source  => [
                 "puppet:///modules/nrpe/role_specific/libexec/${role}",
                 "puppet:///modules/nrpe/role_specific/libexec/default",
               ],
  }
  file {'/usr/local/nagios/etc/nrpe.cfg':
    ensure  => present,
    owner   => 'nagios',
    group   => 'nrpe',
    mode    => '0640',
    content => template('nrpe/nrpe.cfg.base.erb'),
    notify  => Service['nrpe'],
  } ->
  file {'/etc/nagios/nrpe.cfg':
    ensure => link,
    target => '/usr/local/nagios/etc/nrpe.cfg',
    notify => Service['nrpe'],
  }
}
