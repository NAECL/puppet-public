# This module contains the default configuration common to all servers.
class base (
  $role             = 'base',
  $domain           = 'local',
  $install_packages = true,
) {
  $servername       = $::custom_hostname

  # classes that require ordering
  class {'base::config': } ->
  class {'base::services': }

  # Required Classes
  include stdlib
  include ntp
  include hosts
}
