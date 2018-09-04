class mailhub::rainloop {

  package {['apache2','php7.0','libapache2-mod-php7.0','php7.0-curl','php7.0-xml']:
    ensure => present,
  } ->

  file {'/etc/letsencrypt':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  } ->

  file {'/etc/letsencrypt/archive':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  } ->

  # file {'/etc/letsencrypt/options-ssl-apache.conf':
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0644',
    # source  => 'puppet:///modules/mailhub/letsencrypt/options-ssl-apache.conf',
  # } ->

  # file {'/etc/letsencrypt/archive/mail.zoesalt.com':
    # ensure  => directory,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0644',
    # recurse => true,
    # purge   => true,
    # force   => true,
    # source  => 'puppet:///modules/mailhub/letsencrypt/archive/mail.zoesalt.com',
  # } ->

  file {'/etc/letsencrypt/live':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  } ->

  # file {'/etc/letsencrypt/live/mail.zoesalt.com':
    # ensure  => directory,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0755',
    # recurse => true,
    # purge   => true,
    # force   => true,
    # source  => 'puppet:///modules/mailhub/letsencrypt/live/mail.zoesalt.com',
  # } ->

  file {'/etc/apache2/sites-available/rainloop.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => template('mailhub/rainloop/apache.conf.erb'),
    notify => Service['apache2'],
  } ->

  file {'/etc/apache2/sites-available/rainloop-le-ssl.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => template('mailhub/rainloop/apache.conf.ssl.erb'),
    notify => Service['apache2'],
  } ->

  # file {'/etc/apache2/sites-enabled/rainloop.conf':
    # ensure => link,
    # target => '/etc/apache2/sites-available/rainloop.conf',
    # notify => Service['apache2'],
  # } ->

  file {'/etc/apache2/mods-enabled/socache_shmcb.load':
    ensure => link,
    target => '/etc/apache2/mods-available/socache_shmcb.load',
    notify => Service['apache2'],
  } ->

  file {'/etc/apache2/mods-enabled/ssl.load':
    ensure => link,
    target => '/etc/apache2/mods-available/ssl.load',
    notify => Service['apache2'],
  } ->

  file {'/etc/apache2/mods-enabled/ssl.conf':
    ensure => link,
    target => '/etc/apache2/mods-available/ssl.conf',
    notify => Service['apache2'],
  } ->

  # file {'/etc/apache2/sites-enabled/rainloop-le-ssl.conf':
    # ensure => link,
    # target => '/etc/apache2/sites-available/rainloop-le-ssl.conf',
    # notify => Service['apache2'],
  # } ->

  file {'/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
    notify => Service['apache2'],
  } ->

  file {'/usr/local/buildfiles/var.www.rainloop.tar.gz':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => 'puppet:///modules/mailhub/var.www.rainloop.tar.gz',
  } ->
 
  exec {'unpack-var.www.rainloop.tar.gz':
    command => '/bin/tar zxf /usr/local/buildfiles/var.www.rainloop.tar.gz',
    cwd     => '/var/www',
    creates => '/var/www/rainloop',
  } ->

  file {"/var/www/rainloop/data/_data_/_default_/domains/$base::domain.ini":
    ensure => present,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0644',
    content => template('mailhub/rainloop/domain.ini.erb'),
  } ->

  file {'/var/www/rainloop/data/_data_/_default_/configs/application.ini':
    ensure => present,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0644',
    content => template('mailhub/rainloop/application.ini.erb'),
  }

  service {'apache2':
    enable => true,
    ensure => running,
  }
}
