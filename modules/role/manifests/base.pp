class role::base {
  $role = 'base'
  class {'base': role => $role, }
}
