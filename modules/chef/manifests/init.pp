class chef {
  class {'jenkins::install': } ->
  class {'jenkins::config': }
}
