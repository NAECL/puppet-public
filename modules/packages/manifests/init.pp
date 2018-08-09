class packages {
    package {[
        'bind-utils',
        'telnet',
        'wget',
    ]:
        ensure => present,
    }
}
