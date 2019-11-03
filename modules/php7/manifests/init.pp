class php7 (
  $minor_version = '4',
) {
  # Configure PHP Version

  file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-remi':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/php7/RPM-GPG-KEY-remi',
  }

  file { '/etc/yum.repos.d/remi-php7.repo':
    ensure  => present,
    content => template('php7/remi-php7.repo.erb'),
  }

}
