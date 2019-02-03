class nrpe (
  $role = $base::role,
) {
  class { 'nrpe::params': } ->
  class { 'nrpe::packages': } ->
  class { 'nrpe::config': role => $role, } ->
  class { 'nrpe::service': }
}
