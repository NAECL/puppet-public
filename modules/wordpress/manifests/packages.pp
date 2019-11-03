class wordpress::packages {

  package {[
      'httpd',
      'stress',
      'certbot',
      'python2-certbot-apache',
      'ImageMagick',
      'vsftpd',
    ]:
    ensure => present,
  }
}
