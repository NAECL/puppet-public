class role::jenkins_build {
  $role = 'jenkins'
  class {'base': role => $role, } ->
  class {'jenkins': }
}
