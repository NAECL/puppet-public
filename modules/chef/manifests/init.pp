class chef (
  $username  = '',
  $firstname = '',
  $lastname  = '',
  $password  = '',
  $orgname   = '',
  $email     = '',
) {
  class {'chef::install': } ->
  class {'chef::config': }
}
