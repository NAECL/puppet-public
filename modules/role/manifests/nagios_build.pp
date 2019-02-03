class role::nagios_build {
  $role = 'nagios'
  class {'base': role => $role, } ->
  class {'nagios': }
}
