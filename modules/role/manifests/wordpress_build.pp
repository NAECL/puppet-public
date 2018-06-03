class role::wordpress_build {
  $role = 'wordpress'
  class {'base': role => $role, } ->
  class {'wordpress': }
}
