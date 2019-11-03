class packages {
    # Common Packages

    package {[
        'telnet',
        'mlocate',
        'wget',
    ]:
        ensure => present,
    }

    # RedHat Specific Packages
    if ( $::osfamily == 'redhat' ) {
        package {[
            'bind-utils',
            'perl-MIME-tools',
        ]:
            ensure => present,
        }
    }

    # Placeholder for Debian Specific Packages
    # if ( $::osfamily == 'Debian' ) {
    # }
}
