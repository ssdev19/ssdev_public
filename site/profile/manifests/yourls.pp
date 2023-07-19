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
    cleanup      => false,
  }
  # file { '/etc/nginx/YOURLS':
  #           ensure  => present,
  #           source  => "/etc/nginx/YOURLS-${yourls_version}",
  #           recurse => 'remote',
  # }
  file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
            ensure => present,
            source => "/etc/nginx/YOURLS-${yourls_version}/user/config-sample.php",
  }
  -> file_line{ 'change pf.provisioner.mode to STANDALONE':
    match => "define( 'YOURLS_DB_NAME', 'yourls' );",
    line  => "define( 'YOURLS_DB_NAME', 'yourlsTest' );",
    path  => "/etc/nginx/YOURLS-${yourls_version}/user/config.php",
  }
  file { YOURLS:
    ensure => link,
    target => "/etc/nginx/YOURLS-${yourls_version}",
    mode   => 'a=rx,u+w',
  }
  }



}
