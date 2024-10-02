class wordpress::packages {

  if ( $::operatingsystem == 'CentOS' and $::operatingsystemmajrelease == '9' ) {
    package {[
      'python3-certbot-apache',
      ]:
      ensure => present,
    }
  } else {
    package {[
      'python2-certbot-apache',
      ]:
      ensure => present,
    }
  }

  package {[
      'php',
      'php-xml',
      'php-gd',
      'unzip',
      'httpd',
      'stress',
      'certbot',
      'ImageMagick',
      'php-mysqlnd',
      'vsftpd',
    ]:
    ensure => present,
  }
}
