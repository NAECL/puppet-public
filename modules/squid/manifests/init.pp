class squid {
  class {'squid::packages': } ->
  class {'squid::config': }
}
