class base::services (
  $firewall_enable = 'false',
  $firewall_state  = 'stopped',
) {

  service {'crond':
    ensure => running,
    enable => true,
  }

  if ( $::operatingsystemmajrelease == '6' ) {
    service { 'iptables':
      enable => $firewall_enable,
      ensure => $firewall_state,
    }
  }
}
