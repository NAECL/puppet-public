class jenkins::packages {
  file {'/etc/yum.repos.d/jenkins.repo':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/jenkins/jenkins.repo'
  } ->

  package {'jenkins':
    ensure => present,
  } ->

  package {'java-1.8.0-openjdk':
    ensure => present,
  }
}
