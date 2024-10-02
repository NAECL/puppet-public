class firewalld::packages {

  case $operatingsystemmajrelease {
    '7': {
      package {'firewalld':
        ensure => 'present',
      }
    }
    '6': {
      package {'iptables':
        ensure => 'present',
      }
    }
  }
}
