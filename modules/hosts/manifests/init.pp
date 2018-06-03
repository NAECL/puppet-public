class hosts (
  $entries = [],
) {
  file { '/etc/hosts':
    ensure  => present,
    content => template('hosts/hosts.erb'),
  }
}
