class role::base_build {
  $role = 'base'
  class {'base': role => $role, }
}
