class base::root_user (
  # default password is set to password - obviously this should be changed
  $root_password      = '$1$7KzSfIzY$ziNEsyO6x9QVCwSxKhb6J1',
) {

  user {'root':
    password       => $root_password,
    home           => '/root',
  } ->
  file {'/root/.ssh':
    ensure  => directory,
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    require => User['root'],
  } ->
  file {'/root/.ssh/config':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  } -> 
  file_line {'/root/.ssh/config':
    path   => '/root/.ssh/config',
    line   => 'StrictHostKeyChecking no',
    match  => 'StrictHostKeyChecking',
  }
}
