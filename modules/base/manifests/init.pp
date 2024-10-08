# This module contains the default configuration common to all servers.
class base (
  $role     = 'base',
  $sub_role = undef,
  $domain   = 'local.com',
  $hostname = undef,
  $project  = 'unassigned',
) {
  # Hostname is provided by a custom fact from /etc/build_custom_config
  #
  if ( $hostname == undef ) {
    $servername = $::custom_hostname
  } else {
    $servername = $hostname
  }

  # classes that require ordering
  class {'base::config': } ->
  class {'base::services': }

  # Required Classes
  include stdlib
  include ntp
  include hosts
  include packages
  include clam
  include nrpe
  include sysctl
}
