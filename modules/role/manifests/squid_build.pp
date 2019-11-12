class role::squid_build {
  $role = 'squid'
  class {'base': role => $role, } ->
  class {'squid': }
}
