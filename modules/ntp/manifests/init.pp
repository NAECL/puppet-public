class ntp (
  $servers = undef,
) {
  include ntp::install
  include ntp::service
  include ntp::config
}
