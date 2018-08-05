define createWebsite (
  $sitename,
  $dbname,
  $sslcert = 'false',
) {
  file {"/etc/httpd/conf.d/$sitename.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('wordpress/virtual_hosts.conf.erb'),
    notify  => Service['httpd'],
  }

  if ($sslcert == 'true') {
    file {"/etc/httpd/conf.d/$sitename-le-ssl.conf":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('wordpress/virtual_hosts.ssl.conf.erb'),
        notify  => Service['httpd'],
    }
  } else {
    file {"/etc/httpd/conf.d/$sitename-le-ssl.conf":
        ensure  => absent,
    }
  }

  exec {"setup-web-$dbname":
    command => "/usr/local/buildfiles/create_new_website.sh $sitename",
    creates => "/usr/local/puppetbuild/locks/$sitename.webcreated.lck",
    require => File['/usr/share/wordpress/wp-config.php'],
  } ->

  file {"/var/www/$sitename":
    ensure  => directory,
    owner   => 'apache',
    group   => 'apache',
    recurse => true,
  } ->

  file {"/var/www/$sitename/private":
    ensure  => link,
    target  => "/var/www/$sitename/static",
  } ->

  file {"/var/www/$sitename/static":
    ensure  => directory,
    owner   => 'apache',
    group   => 'apache',
    mode    => '0750',
    recurse => true,
    source  => [ "puppet:///modules/wordpress/static/$sitename", "puppet:///modules/wordpress/static/default" ],
  } ->

  exec {"setup-mysql-$dbname":
    command => "/usr/local/buildfiles/setup-mysql -n $dbname $sitename",
    creates => "/usr/local/puppetbuild/locks/$dbname.dbcreated.lck",
    require => File['/etc/wordpress'],
  }

  file {"/usr/local/buildfiles/$sitename.png":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => "puppet:///modules/wordpress/$sitename.png",
  }
}

class wordpress::config (
  $sites          = [],
  $install_opsweb = undef,
) {

  $wpversion = hiera('wordpress/version','4.9.1')

  file {'/etc/php.ini':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/wordpress/php.ini',
  }

  file {'/usr/local/bin/renew_certs.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/renew_certs.sh',
  }

  file {'/usr/local/bin/watermark_websites.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/watermark_websites.sh',
  }

  cron { 'watermark_websites':
    command => '/usr/local/bin/watermark_websites.sh > /dev/null 2>&1',
    user    => 'root',
    hour    => 1,
    minute  => 0,
  }

  cron { 'renew_certs':
    command => '/usr/local/bin/renew_certs.sh > /dev/null 2>&1',
    user    => 'root',
    hour    => 1,
    minute  => 23,
  }

  file {'/usr/local/bin/backup_websites.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/backup_websites.sh',
  }

  cron { 'backup_websites':
    command => '/usr/local/bin/backup_websites.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 3,
    minute  => 0,
  }

  file {'/usr/local/bin/watermarkSite.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/watermarkSite.sh',
  }

  file {'/usr/local/bin/createWatermarkFile.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/createWatermarkFile.sh',
  }

  file {'/usr/local/bin/watermarkFile.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/watermarkFile.sh',
  }

  file {'/usr/local/config/dir_clean.wordpressdb.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('wordpress/dir_clean.wordpressdb.conf.erb'),
  }

  cron { '/usr/local/config/dir_clean.wordpressdb.conf':
    command => '/usr/local/bin/dir_clean -f /usr/local/config/dir_clean.wordpressdb.conf >> /var/log/dir_clean.wordpressdb.log 2>&1',
    user    => 'root',
    hour    => 2,
    minute  => 0,
  }

  exec {"download-wordpress-$wpversion.tar.gz":
    command => "/usr/bin/wget http://aws.naecl.co.uk/public/build/dsl/wordpress-$wpversion.tar.gz",
    creates => "/usr/local/buildfiles/wordpress-$wpversion.tar.gz",
    cwd     => '/usr/local/buildfiles',
  } ->

  file {"/usr/local/buildfiles/wordpress-$wpversion.tar.gz":
    owner => 'root',
  } ->

  exec {'create-usr-share-wordpress':
    command => "/bin/tar zxf /usr/local/buildfiles/wordpress-$wpversion.tar.gz",
    cwd     => '/usr/share',
    creates => '/usr/share/wordpress',
  } ->

  file {'/usr/share/wordpress/wp-config.php':
    source  => "puppet:///modules/wordpress/wp-config-$wpversion.php",
  } ->

  file {'/etc/wordpress':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  file {'/usr/local/buildfiles/setup-mysql-root':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/setup-mysql-root',
  } ->

  exec {'/root/.my.cnf':
    creates => '/root/.my.cnf',
    command => '/usr/local/buildfiles/setup-mysql-root',
  } ->

  file {'/root/.my.cnf':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  file {'/etc/httpd/logs':
    ensure => link,
    target => '../../var/log/httpd',
  } ->

  service {'httpd':
    enable => true,
    ensure => running,
  }

  file {'/usr/local/buildfiles/create_new_website.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/create_new_website.sh',
  }

  file {'/usr/local/buildfiles/setup-mysql':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/setup-mysql',
  }

  file {'/usr/local/bin/backup_wordpress.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/backup_wordpress.sh',
  }

  file {'/var/lib/mysql-backups':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
  }

  create_resources(createWebsite, $sites)
}
