class chef (
  $username,
  $firstname,
  $lastname,
  $password,
  $orgshortname,
  $orglongname,
  $email,
  $role = 'client',
) {
  if ( $role == 'client' ) {
    class {'chef::client': }
  } else {
    class {'chef::master': }
  }
}
