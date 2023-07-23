# 
class profile::yourls ( String

$yourls_version,
$yourls_site,


){
  include nginx
  include mysql::server
  include '::php'

# class { '::php::globals':
#   php_version => '7.3',
#   config_root => '/etc/php/',
# }
# -> class { '::php':
#     manage_repos => true,
#     ensure       => '7.3.27',
# }

  Package { [ 'openldap-devel' ]:
    ensure => installed,
  }
$yourls_user_passwords = lookup('yourls_user_passwords')
$yourls_db_pass = lookup('yourls_db_pass')
$yourls_db_user = lookup('yourls_db_user')
$yourls_db_name = lookup('yourls_db_name')

  unless $::yourls_config  {
  archive { "/tmp/yourls-${yourls_version}.tar.gz":
    ensure       => present,
    source       => "https://github.com/YOURLS/YOURLS/archive/refs/tags/${yourls_version}.tar.gz",
    extract_path => '/etc/nginx',
    extract      => true,
    provider     => 'wget',
    cleanup      => false,
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
  archive { '/tmp/nginx-auth-ldap.tar.gz':
    ensure       => present,
    source       => 'https://github.com/kvspb/nginx-auth-ldap/archive/refs/tags/v0.1.tar.gz',
    extract_path => '/tmp/',
    extract      => true,
    provider     => 'wget',
    cleanup      => true,
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
#   file_line { 'Add yourls users':
#       match => 'username => password',
#       line  => $yourls_user_passwords,
#       path  => "/etc/nginx/YOURLS-${yourls_version}/user/config.php",
#   }
file { '/etc/nginx/YOURLS':
  ensure => 'link',
  target => "/etc/nginx/YOURLS-${yourls_version}",
}
  # nginx::resource::server { 'yourls':
  #   ensure                => present,
  #   listen_port           => 80,
  #   www_root              => '/etc/nginx/YOURLS',
  #   # proxy                 => $proxy,
  #   # location_cfg_append   => $location_cfg_append,
  #   index_files           => [ 'index', 'index.php', 'index.html', 'index.htm' ],
  #   # ssl                   => true,
  #   # ssl_cert              => '/etc/pki/tls/certs/ls.st.current.crt',
  #   # ssl_key               => '/etc/pki/tls/certs/ls.st.current.key',
  # }
    nginx::resource::location { 'root':
      ensure         => 'present',
      try_files  => ['$uri $uri/ /yourls-loader.php$is_args$args'],
      # location       => '~* ^/LSO[\ -]([0-9]+)$',
      fastcgi        => "unix:/var/run/php-fpm/nginx-fpm.sock",
      # location_alias => ' https://docushare.lsst.org/docushare/dsweb/Get/LDM-$1',
      # maintenance_value => 'return 301',
      # index_files    => ['index', 'index.php', 'index.html', 'index.htm'],
      server         => 'yourls',
      location    =>  '~ \.php$',
      include     => ['fastcgi.conf'],
  }

# exec {'compile':
#   path    => [  '/tmp/nginx-auth-ldap-0.1' ],
#   command => './configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=nginx --group=nginx --add-module=./nginx-auth-ldap',
#   provider => 'shell',
# }
  archive { '/tmp/mysql-db-yourls.gz' :
    ensure  => present,
    source  => 's3://yourls-data/20230304191601-mysql-db-yourls.gz',
    cleanup => false,
  }
  if $::yourls_db  {
    mysql::db { $yourls_db_name:
      user            => $yourls_db_user,
      password        => $yourls_db_pass,
      host            => 'localhost',
      grant           => ['SELECT', 'UPDATE'],
      sql             => ['/tmp/mysql-db-yourls.gz'],
      import_cat_cmd  => 'zcat',
      import_timeout  => 900,
      # mysql_exec_path => '/opt/rh/rh-myql57/root/bin',
    }
  }
  php::fpm::pool{'nginx':
    user         => 'nginx',
    group        => 'nginx',
    listen_owner => 'nginx',
    listen_group => 'nginx',
    listen_mode  => '0660',
    listen       => "/var/run/php-fpm/nginx-fpm.sock",
  }
}
