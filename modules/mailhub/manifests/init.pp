class mailhub {

  class {'mailhub::params': } ->
  class {'mailhub::packages': } ->
  class {'mailhub::postfix': } ->
  class {'mailhub::dovecot': } ->
  class {'mailhub::rainloop': } ->
  class {'mailhub::config': }
}
