class chef (
  $username,
  $firstname,
  $lastname,
  $password,
  $orgshortname,
  $orglongname,
  $email,
) {
  class {'chef::master': }
}
