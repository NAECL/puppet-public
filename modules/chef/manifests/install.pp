class chef::install (
  version = 'undef',
) {
  if ${
  exec {'download-chef-rpm':
    command => "/usr/bin/wget http://aws.naecl.co.uk/public/build/dsl/wordpress-$wordpress_version.tar.gz",
    creates => "/usr/local/buildfiles/wordpress-$wordpress_version.tar.gz",
    cwd     => '/usr/local/buildfiles',
  } ->

  file {"/usr/local/buildfiles/wordpress-$wordpress_version.tar.gz":
    owner => 'root',
  } ->

  exec {'create-usr-share-wordpress':
    command => "/bin/tar zxf /usr/local/buildfiles/wordpress-$wordpress_version.tar.gz",
    cwd     => '/usr/share',
    creates => '/usr/share/wordpress',
  } ->
}
