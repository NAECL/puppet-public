class nrpe::packages {
  # Find what plugins are available with yum list nagios-plugins*
  #
  package { [
        'nrpe',
        'nagios-plugins-all',
    ]:
    ensure => present,
  }

  package {'perl-DateTime-Format-DateParse':
    ensure => present,
  }
}
