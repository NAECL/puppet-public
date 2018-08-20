class role::mailhub_build {
  $role = 'mailhub'
  class {'base': role => $role, } ->
  class {'mailhub': }
}
