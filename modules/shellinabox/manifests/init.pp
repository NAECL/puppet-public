class docker {
  file {'/etc/sysconfig/shellinaboxd':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/shellinabox/sysconfig/shellinaboxd',
  }

  package {'shellinaboxd':
    ensure => present,
  } ->

  service {'shellinaboxd':
    ensure => running,
    enable => true,
  } -> 
}
