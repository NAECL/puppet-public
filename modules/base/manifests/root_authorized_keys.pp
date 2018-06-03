class base::root_authorized_keys($keys) {

  define add_authorized_keys {
    $_parts = split($title, " ")

    if size($_parts) == 3 {
      $_type = $_parts[0]
      $_key  = $_parts[1]
      $_tag  = $_parts[2]

      ssh_authorized_key {
        "root-${_tag}":
          user    => 'root',
          ensure  => present,
          type    => $_type,
          key     => $_key,
          require => File['/root/.ssh'],
      }
    }
  }

  $root_authorized_keys = any2array($keys)

  if ! empty($root_authorized_keys[0]) {
    add_authorized_keys { $root_authorized_keys: }
  }

}
