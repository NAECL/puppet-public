class wordpress::packages {

  package {[
      'php',
      'php-xml',
      'httpd',
      'stress',
      'ImageMagick',
      'php-mysql',
      'vsftpd',
    ]:
    ensure => present,
  }
}
