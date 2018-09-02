class mailhub (
  $relay             = undef,
  $mailgroup         = '5000',
  $mailuser          = '5000',
  $virtual_aliases   = undef,
  $virtual_mailboxes = undef,
) {
  class {'mailhub::packages': } ->
  class {'mailhub::postfix': } ->
  class {'mailhub::dovecot': } ->
  class {'mailhub::rainloop': } ->
  class {'mailhub::config': }
}
