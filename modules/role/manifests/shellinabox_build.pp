class role::shellinabox_build {
  $role = 'shellinabox'
  class {'base': role => $role, } ->
  class {'shellinabox': }
}
