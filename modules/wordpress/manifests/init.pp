class wordpress (
  $wordpress_version => '4.9.1',
) {
  class {'wordpress::packages': } ->
  class {'wordpress::database': } ->
  class {'wordpress::config': }
}
