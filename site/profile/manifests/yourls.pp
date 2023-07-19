# 
class profile::yourls {
  include nginx
  include mariadb::server
  include '::php'

  unless $::yourls_config  {
  archive { '/tmp/yourls-1.9.2.tar.gz':
    ensure       => present,
    source       => 'https://github.com/YOURLS/YOURLS/archive/refs/tags/1.9.2.tar.gz',
    extract_path => '/etc/nginx',
    extract      => true,
    provider     => 'wget',
    cleanup      => false,
  }
  file { '/etc/nginx/YOURLS':
            ensure  => present,
            source  => '/etc/nginx/YOURLS-1.9.2',
            recurse => 'remote',
  }
  file { '/etc/nginx/YOURLS/user/config.php':
            ensure => present,
            source => '/etc/nginx/YOURLS/user/config-sample.php',
  }
  }
}
