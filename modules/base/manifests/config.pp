class base::config (
  $aws_server          = 'false',
  $reboot_after_update = 'false',
) {
  $role = $base::role

  # O/S specific settings
  case $::operatingsystem {
    'CentOS' : {
      file_line {'hostname_/etc/sysconfig/network':
        path   => '/etc/sysconfig/network',
        line   => "HOSTNAME=$base::servername.$base::domain",
        match  => '^HOSTNAME=',
      }
      file {'/etc/hostname':
        ensure  => present,
        content => "$base::servername.$base::domain\n",
      }
      file_line {'update_method_/etc/build_custom_config':
        path    => '/etc/build_custom_config',
        line    => "UPDATE_METHOD=yum",
        match   => '^UPDATE_METHOD=',
        require => File['/etc/build_custom_config'],
      }
    }
    'Ubuntu' : {
      file_line {'update_method_/etc/build_custom_config':
        path    => '/etc/build_custom_config',
        line    => "UPDATE_METHOD=apt",
        match   => '^UPDATE_METHOD=',
        require => File['/etc/build_custom_config'],
      }
      file {'/etc/hostname':
        ensure  => present,
        content => "$base::servername.$base::domain\n",
      }
    }
    default  : { }
  }

  file {'/etc/build_custom_config':
    ensure => present,
    mode   => '0750',
    owner  => 'root',
    group  => 'root',
  } ->

  file_line {'reboot_after_update_/etc/build_custom_config':
    path   => '/etc/build_custom_config',
    line   => "REBOOT_AFTER_UPDATE=${reboot_after_update}",
    match  => '^REBOOT_AFTER_UPDATE=',
  } ->

  file_line {'domain_/etc/build_custom_config':
    path   => '/etc/build_custom_config',
    line   => "DOMAIN=${base::domain}",
    match  => '^DOMAIN=',
  } ->

  file_line {'role_/etc/build_custom_config':
    path   => '/etc/build_custom_config',
    line   => "ROLE=$role",
    match  => '^ROLE=',
  } ->

  file_line {'netmask_/etc/build_custom_config':
    path => '/etc/build_custom_config',
    line => "NETMASK=${::netmask}",
    match => '^NETMASK=',
  } ->

  file_line {'ipaddr_/etc/build_custom_config':
    path => '/etc/build_custom_config',
    line => "IPADDR=${::ipaddress}",
    match => '^IPADDR=',
  }

  file {'usr-local-config':
    name => '/usr/local/config',
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0755',
  }

  file {'/usr/local/bin':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/base/local.bin',
  }

  file { [ "/usr/local/puppetbuild", "/usr/local/puppetbuild/locks" ]:
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => '700',
  }

  file {'/usr/local/buildfiles':
    name => '/usr/local/buildfiles',
    ensure => directory,
    owner => 'root',
    group => 'root',
    recurse => true,
    purge   => true,
    force   => true,
    mode => '0755',
  }

  $ip_address = $facts[networking']['ip']
  file {'/etc/motd':
    ensure   => present,
    owner    => root,
    group    => root,
    mode     => '0644',
    content  => template('base/motd.erb'),
  }

  if ( $aws_server == 'true' ) {
    file {'/etc/cloud/cloud.cfg.d/99_hostname.cfg':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0750',
      content  => "#cloud-config\nhostname: $base::servername\nfqdn: $base::servername.$base::domain\n",
    }
  }

  file {'/root/.bashrc':
    ensure   => present,
    owner    => root,
    group    => root,
    mode     => '0750',
    source  => 'puppet:///modules/base/root-bashrc',
  }

  # Hack for systems without selinux installed, still create this file
  file {'/etc/selinux/config':
    ensure => present,
  } ->
  file_line {'disable-selinux':
    path   => '/etc/selinux/config',
    line   => "SELINUX=disabled",
    match  => '^SELINUX=',
  }

  cron { 'update-repos':
    command => '/usr/local/bin/patch_os.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 5,
    minute  => 0,
  }
}
