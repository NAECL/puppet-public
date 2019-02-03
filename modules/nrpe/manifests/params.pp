class nrpe::params (
  $nrpe_max_alert_level = 'critical',
  $allowed_hosts        = '',
  $blame_nrpe           = '1',
) {
  include stdlib

  $nrpe_allowed = join($allowed_hosts,',')

  # If nrpe_max_alert_level is anything but warning or critical, there will be an error
  $max_alert_level = downcase($nrpe_max_alert_level)
  if $max_alert_level == 'critical' {
    $critical_alert = 2
  }
  if $max_alert_level == 'warning' {
    $critical_alert = 1
  }
}
