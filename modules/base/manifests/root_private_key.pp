class base::root_private_key(
  $root_private_key = undef,
) {

  if $root_private_key != '' {
    file {'/root/.ssh/id_rsa':
      ensure  => present,
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      content => $root_private_key,
      require => File['/root/.ssh'],
    }
  }
}
