class role::docker_build {
  $role = 'docker'
  class {'base': role => $role, } ->
  class {'docker': }
}
