class wordpress::database {

  if ( $::operatingsystemmajrelease == '7' ) {
    $packages = [ 'mariadb', 'mariadb-server' ]
    $service  = 'mariadb'
  } else {
    $packages = [ 'mysql', 'mysql-server' ]
    $service  = 'mysqld'
  }

  package { $packages:
    ensure => present,
  } ->

  service {$service:
    enable => true,
    ensure => running,
  }
}
