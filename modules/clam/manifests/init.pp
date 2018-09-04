class clam (
  $install = 'false',
) {
  if ( $install == 'true' ) {
    if ( $::osfamily == 'Debian' ) {
      package { 'clamav':
        ensure => present,
      } ->

      package { 'clamav-daemon':
        ensure => present,
      } ->

      service { 'clamav-daemon':
        enable => true,
        ensure => running,
      } ->

      service { 'clamav-freshclam':
        enable => true,
        ensure => running,
      }
    }

    # if ( $::osfamily == 'redhat' ) {
    # }
  }
}
