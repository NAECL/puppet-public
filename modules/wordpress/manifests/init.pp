class wordpress (
  $wordpress_version = '5.0.2',
) {
  class {'wordpress::packages': } ->
  class {'wordpress::database': } ->
  class {'wordpress::config': }
}
