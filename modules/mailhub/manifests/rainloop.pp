class mailhub::rainloop (
  # This url should be set to an internal controlled DSL, but this will work for POC
  $package_location = 'https://github.com/RainLoop/rainloop-webmail/releases/download',
  $package_version  = '1.12.1',
) {
  $package_url = "${package_location}/v${package_version}/rainloop-${package_version}.zip",

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

  file {'/etc/letsencrypt/live':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  } ->

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

  file {'/etc/apache2/sites-enabled/rainloop.conf':
    ensure => link,
    target => '/etc/apache2/sites-available/rainloop.conf',
    notify => Service['apache2'],
  } ->

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

  file {'/etc/apache2/sites-enabled/rainloop-le-ssl.conf':
    ensure => link,
    target => '/etc/apache2/sites-available/rainloop-le-ssl.conf',
    notify => Service['apache2'],
  } ->

  file {'/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
    notify => Service['apache2'],
  } ->

  exec {'download_rainloop.zip':
    command => "/usr/bin/wget -O /usr/local/buildfiles/rainloop.${package_version}.zip $package_url",
    cwd     => '/usr/local/buildfiles',
    creates => "/usr/local/buildfiles/rainloop.${package_version}.zip",
  } ->

  # Make sure puppet knows about this file, and leaves it alone
  file {"/usr/local/buildfiles/rainloop.${package_version}.zip":
    owner => 'root',
  } ->

  # Create directory for the new version
  file {"/var/www/rainloop_${package_version}":
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  } ->

  # Ensure that rainloop link points to correct place before packags is unzipped
  file {'/var/www/rainloop':
    ensure => link,
    target => "/var/www/rainloop_${package_version}",
  } ->
 
  exec {'unzip_rainloop.zip':
    command => "/usr/bin/unzip /usr/local/buildfiles/rainloop.${package_version}.zip",
    cwd     => '/var/www/rainloop',
    creates => '/var/www/rainloop/rainloop',
  } ->

  # Set perms after tar
  file {'/var/www/rainloop/rainloop':
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
  } ->
  file {'/var/www/rainloop/index.php':
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
  } ->
  file {'/var/www/rainloop/data':
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
  } ->

  file {'/var/www/rainloop/data/_data_':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  } ->

  file {'/var/www/rainloop/data/_data_/_default_':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  } ->

  file {'/var/www/rainloop/data/_data_/_default_/configs':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  } ->

  file {'/var/www/rainloop/data/_data_/_default_/domains':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
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
