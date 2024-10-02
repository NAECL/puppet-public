define firewalld::createServiceFiles {

  file { "/usr/lib/firewalld/services/$title":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['firewalld.service'],
    source => "puppet:///modules/firewalld/services/$title",
  }
}

class firewalld(
  $role          = 'base',
  $reject_addrs  = 'undef'
) {
  class {'firewalld::packages': } ->
  class {'firewalld::config': }
}
