class mailhub::params {
  $relay      = hiera('mailhub/relay','relay.zoesalt.com')
  $mailgroup  = hiera('mailhub/mailgroup','5000')
  $mailuser   = hiera('mailhub/mailuser','5000')
}
