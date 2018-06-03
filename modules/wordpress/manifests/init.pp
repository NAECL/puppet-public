class wordpress {
  class {'wordpress::packages': } ->
  class {'wordpress::database': } ->
  class {'wordpress::config': }
}
