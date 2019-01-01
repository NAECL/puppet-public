define wordpress::createwebsite (
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

  exec {"create_/usr/local/buildfiles/$sitename.png":
    command => "/usr/local/bin/watermark_websites.sh $sitename 1"
    cwd     => '/usr/local/buildfiles',
    creates => "/usr/local/buildfiles/$sitename.png",
    require => File['/usr/local/bin/watermark_websites.sh'],
  }
}
