class {'packages':
    package {[
        'wget',
    ]:
        ensure => present,
    }
}
