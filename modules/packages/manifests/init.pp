class packages {
    package {[
        'wget',
        'bind-utils',
    ]:
        ensure => present,
    }
}
