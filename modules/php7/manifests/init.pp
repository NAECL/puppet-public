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

}
