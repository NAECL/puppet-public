class jenkins::config {
  service {'jenkins':
    ensure => running,
    enable => true,
  }
}
