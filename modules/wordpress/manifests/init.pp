class wordpress (
  $wordpress_version = '5.0.2',
  $wordpress_type    = 'tar.gz',
) {
  class {'wordpress::packages': } ->
  class {'wordpress::database': } ->
  class {'wordpress::config': }
}
