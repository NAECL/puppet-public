class wordpress::config (
  $sites          = [],
  $install_opsweb = undef,
  $backup_bucket  = 'ignore',
) {

  $wp_version = $wordpress::wordpress_version
  $wp_type = $wordpress::wordpress_type

  if ($wp_type == 'zip') {
    $unpack_cmd = '/bin/unzip'
  } else {
    $unpack_cmd = '/bin/tar xzf'
  }

  file {'/etc/php.ini':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/wordpress/php.ini',
  }

  file {'/usr/local/bin/watermark_websites.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/watermark_websites.sh',
  }

  cron { 'watermark_websites':
    command => '/usr/local/bin/watermark_websites.sh > /dev/null 2>&1',
    user    => 'root',
    hour    => 1,
    minute  => 0,
  }

  cron { 'restart mariadb service':
    command => '/usr/local/bin/restart_service.sh mariadb > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/3',
  }

  cron { 'renew_certs':
    command => '/usr/local/bin/renew_certs.sh > /dev/null 2>&1',
    user    => 'root',
    hour    => 1,
    minute  => 23,
  }

  file {'/usr/local/bin/copy_website.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/copy_website.sh',
  }

  file {'/usr/local/bin/backup_websites.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/backup_websites.sh',
  }

  file {'/usr/local/bin/restore_wordpress_backup.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/restore_wordpress_backup.sh',
  }

  cron { 'backup_websites':
    command => '/usr/local/bin/backup_websites.sh >/dev/null 2>&1',
    user    => 'root',
    hour    => 3,
    minute  => 0,
  }

  file {'/usr/local/bin/watermarkSite.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/watermarkSite.sh',
  }

  file {'/usr/local/bin/createWatermarkFile.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/createWatermarkFile.sh',
  }

  file {'/usr/local/bin/watermarkFile.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/watermarkFile.sh',
  }

  file {'/usr/local/config/dir_clean.wordpressdb.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('wordpress/dir_clean.wordpressdb.conf.erb'),
  }

  cron { '/usr/local/config/dir_clean.wordpressdb.conf':
    command => '/usr/local/bin/dir_clean -f /usr/local/config/dir_clean.wordpressdb.conf >> /var/log/dir_clean.wordpressdb.log 2>&1',
    user    => 'root',
    hour    => 2,
    minute  => 0,
  }

  exec {"download-wordpress-$wp_version.$wp_type":
    command => "/usr/bin/wget http://aws.naecl.co.uk/public/build/dsl/wordpress-$wp_version.$wp_type",
    creates => "/usr/local/buildfiles/wordpress-$wp_version.$wp_type",
    cwd     => '/usr/local/buildfiles',
  } ->

  file {"/usr/local/buildfiles/wordpress-$wp_version.$wp_type":
    owner => 'root',
  } ->

  exec {'create-usr-share-wordpress':
    command => "$unpack_cmd /usr/local/buildfiles/wordpress-$wp_version.$wp_type",
    cwd     => '/usr/share',
    creates => '/usr/share/wordpress',
  } ->

  file {'/usr/share/wordpress/wp-config.php':
    source  => "puppet:///modules/wordpress/wp-config-$wp_version.php",
  } ->

  file {'/etc/wordpress':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  file {'/usr/local/buildfiles/setup-mysql-root':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/setup-mysql-root',
  } ->

  exec {'/root/.my.cnf':
    creates => '/root/.my.cnf',
    command => '/usr/local/buildfiles/setup-mysql-root',
  } ->

  file {'/root/.my.cnf':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  file {'/etc/httpd/logs':
    ensure => link,
    target => '../../var/log/httpd',
  } ->

  service {'httpd':
    enable => true,
    ensure => running,
  }

  file {'/usr/local/buildfiles/create_new_website.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/create_new_website.sh',
  }

  file {'/usr/local/buildfiles/setup-mysql':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/setup-mysql',
  }

  file {'/usr/local/bin/backup_wordpress.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    source  => 'puppet:///modules/wordpress/backup_wordpress.sh',
  }

  file {'/var/lib/mysql-backups':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
  }

  file_line {'backup_bucket_/etc/build_custom_config':
    path   => '/etc/build_custom_config',
    line   => "BACKUP_BUCKET=${wordpress::config::backup_bucket}",
    match  => '^BACKUP_BUCKET=',
  }

# For now just make sure puppet doesn't remove aws. Long term use exec to invoke installer
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

  file {'/usr/local/bin/aws':
    ensure  => present,
  }

  file {'/usr/local/bin/aws_completer':
    ensure  => present,
  }

  create_resources(wordpress::createwebsite, $sites)

  if ($install_opsweb == 'true') {
    include opsweb
  }
}
