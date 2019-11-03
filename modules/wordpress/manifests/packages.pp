class wordpress::packages {

  package {[
      'php',
      'php-xml',
      'httpd',
      'stress',
      'certbot',
      'python2-certbot-apache',
      'ImageMagick',
      'php-mysqlnd',
      'vsftpd',
    ]:
    ensure => present,
  }
}
