class squid (
  $localnet = undef,
) {
  class {'squid::packages': } ->
  class {'squid::config': }
}
