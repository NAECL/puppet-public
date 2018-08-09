class role::chef_build {
  $role = 'chef'
  class {'base': role => $role, } ->
  class {'chef': }
}
