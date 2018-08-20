class mailhub (
  $relay,
  $mailgroup  = '5000')
  $mailuser   = '5000',
) {

  class {'mailhub::packages': } ->
  class {'mailhub::postfix': } ->
  class {'mailhub::dovecot': } ->
  class {'mailhub::rainloop': } ->
  class {'mailhub::config': }
}
