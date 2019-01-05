class jenkins {

  class {'jenkins::params': } ->
  class {'jenkins::packages': } ->
  class {'jenkins::config': }
}
