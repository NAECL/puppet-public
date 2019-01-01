class wordpress::packages {

  package {[
      'php',
      'php-xml',
      'httpd',
      'stress',
      'certbot',
      'ImageMagick',
      'php-mysql',
      'vsftpd',
    ]:
    ensure => present,
  }
}
