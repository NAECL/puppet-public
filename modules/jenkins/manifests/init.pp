class jenkins {
  class {'jenkins::packages': } ->
  class {'jenkins::config': }
}
