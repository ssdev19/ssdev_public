# 
class profile::yourls ( String

$yourls_version,
$yourls_site,

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
  archive { '/tmp/config.php' :
    ensure  => present,
    source  => 's3://yourls-data/config.php',
    cleanup => false,
  }
  file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
    ensure  => present,
    source  => '/tmp/config.php',
    replace => 'yes',
  }
  # file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
  #         ensure => present,
  #         source => "/etc/nginx/YOURLS-${yourls_version}/user/config-sample.php",
  # }

  # file { '/etc/nginx/YOURLS':
  #           ensure  => present,
  #           source  => "/etc/nginx/YOURLS-${yourls_version}",
  #           recurse => 'remote',
  # }

  }
#   file_line { 'Change db username to':
#       match => 'YOURLS_DB_USER',
#       line  => "define( 'YOURLS_DB_USER', 'yourls' );",
#       path  => "/etc/nginx/YOURLS-${yourls_version}/user/config.php",
#   }
#   file_line { 'Change URL to':
#       match => 'YOURLS_SITE',
#       line  => "define( 'YOURLS_SITE', '${yourls_site}' );",
#       path  => "/etc/nginx/YOURLS-${yourls_version}/user/config.php",
#   }
# $yourls_user_passwords = lookup('yourls_user_passwords')
#   file_line { 'Add yourls users':
#       match => 'username => password',
#       line  => $yourls_user_passwords,
#       path  => "/etc/nginx/YOURLS-${yourls_version}/user/config.php",
#   }
file { '/etc/nginx/YOURLS':
  ensure => 'link',
  target => "/etc/nginx/YOURLS-${yourls_version}",
}
  nginx::resource::server { 'yourls':
    ensure   => present,
    www_root => '/etc/nginx/YOURLS',
  }
}
