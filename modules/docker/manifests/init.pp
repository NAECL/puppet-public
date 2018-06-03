class docker {
  file {'/usr/local/docker':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->
  file {'/usr/local/docker/build':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/docker/build',
  }
  # o/s specific hostname
  case $::operatingsystem {
    'centos' : {
      package {'docker':
        ensure => present,
      } ->

      service {'docker':
        ensure => running,
        enable => true,
      } -> 

      user {'centos':
        groups => 'dockerroot',
      }
    }
    'ubuntu' : {
      package {'docker.io':
        ensure => present,
      } ->

      service {'docker':
        ensure => running,
        enable => true,
      } -> 

      user {'ubuntu':
        groups => 'docker',
      }
    }
    default  : { }
  }
}
