class php7 (
  $minor_version = '4',
) {
  # Configure PHP Version - This module will be set to default to the latest as appropriate
  # however an application can be held back using $minor_version

  file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-remi':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/php7/RPM-GPG-KEY-remi',
  } ->

  file { '/etc/yum.repos.d/remi-php7.repo':
    ensure  => present,
    content => template('php7/remi-php7.repo.erb'),
  } ->

  package {[
      'php',
      'php-xml',
      'php-mysqlnd',
    ]:
    ensure => present,
  }

}
