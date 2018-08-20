class mailhub::roundcube {

  file {'/etc/roundcube/config.inc.php':
    ensure  => present,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    content => template('mailhub/config.inc.php.erb'),
  }

  file {'/etc/roundcube/debian-db.php':
    ensure  => present,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    source  => 'puppet:///modules/mailhub/debian-db.php',
  }

  package {['sqlite3', 'php-sqlite3']:
    ensure => present,
  }

# Temporarily, don't install package roundcube
  package {'roundcube':
    ensure => absent,
  }

  package {['roundcube-sqlite3', 'roundcube-plugins', 'roundcube-plugins-extra']:
    ensure => present,
  } -> 

  file {'/var/lib/roundcube/db':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0775',
  } ->

  service {'apache2':
    enable => true,
    ensure => running,
  }

}
