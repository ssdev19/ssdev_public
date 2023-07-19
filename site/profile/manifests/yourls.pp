# 
class profile::yourls ( String

$yourls_version,

){
  include nginx
  include mysql::server
  include '::php'

  unless $::yourls_config  {
  archive { "/tmp/yourls-${yourls_version}.tar.gz":
    ensure       => present,
    source       => "https://github.com/YOURLS/YOURLS/archive/refs/tags/${yourls_version}.tar.gz",
    extract_path => '/etc/nginx',
    extract      => true,
    provider     => 'wget',
    cleanup      => true,
  }
  file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
          ensure => present,
          source => "/etc/nginx/YOURLS-${yourls_version}/user/config-sample.php",
  }

  # file { '/etc/nginx/YOURLS':
  #           ensure  => present,
  #           source  => "/etc/nginx/YOURLS-${yourls_version}",
  #           recurse => 'remote',
  # }

  }
  file_line{ 'Change db username':
      match => 'your db user name',
      line  => "define( 'YOURLS_DB_USER', 'yourls' );",
      path  => "/etc/nginx/YOURLS-${yourls_version}/user/config.php",
  }



}
