# 
class profile::yourls ( String

$yourls_version,
$yourls_site,

){
  # include nginx
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
nginx::resource::server { 'puppet':
  ensure               => present,
  server_name          => ['puppet'],
  listen_port          => 8140,
  ssl                  => true,
  ssl_cert             => '/var/lib/puppet/ssl/certs/example.com.pem',
  ssl_key              => '/var/lib/puppet/ssl/private_keys/example.com.pem',
  ssl_port             => 8140,
  server_cfg_append    => {
    'passenger_enabled'      => 'on',
    'passenger_ruby'         => '/usr/bin/ruby',
    'ssl_crl'                => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    'ssl_client_certificate' => '/var/lib/puppet/ssl/certs/ca.pem',
    'ssl_verify_client'      => 'optional',
    'ssl_verify_depth'       => 1,
  },
  www_root             => '/etc/puppet/rack/public',
  use_default_location => false,
  access_log           => '/var/log/nginx/puppet_access.log',
  error_log            => '/var/log/nginx/puppet_error.log',
  passenger_cgi_param  => {
    'HTTP_X_CLIENT_DN'     => '$ssl_client_s_dn',
    'HTTP_X_CLIENT_VERIFY' => '$ssl_client_verify',
  },
}
}
