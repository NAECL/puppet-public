class mailhub::packages {

  package {[
      'mail-stack-delivery',
      'mailutils',
      'libemail-mime-perl',
      'libmime-tools-perl',
      'python-software-properties',
      'letsencrypt',
      'python-letsencrypt-apache',
    ]:
    ensure => present,
  }
}