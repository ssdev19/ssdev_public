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
    file { "/etc/nginx/YOURLS-${yourls_version}/shorten":
    ensure => directory,
  }
    archive { '/tmp/nginx-1.24.0.tar.gz':
      ensure       => present,
      source       => 'http://nginx.org/download/nginx-1.24.0.tar.gz',
      extract_path => '/tmp/',
      extract      => true,
      provider     => 'wget',
      cleanup      => true,
  }

    vcsrepo { '/tmp/nginx-1.24.0/nginx-auth-ldap':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
      user     => 'root',
    }
file { '/etc/nginx/YOURLS':
  ensure => 'link',
  target => "/etc/nginx/YOURLS-${yourls_version}",
}

  exec {'compile':
    path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
    cwd      => '/tmp/nginx-1.24.0/',
    provider => shell,
    command  => './configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=nginx --group=nginx --add-module=./nginx-auth-ldap',
  }
  archive { '/tmp/mysql-db-yourls.gz' :
    ensure  => present,
    source  => 's3://yourls-data/mysql-db-yourls-202303020300.gz',
    cleanup => false,
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
  if $::yourls_db  {
    mysql::db { $yourls_db_name:
      user           => $yourls_db_user,
      password       => $yourls_db_pass,
      host           => 'localhost',
      grant          => ['SELECT', 'UPDATE'],
      sql            => ['/tmp/mysql-db-yourls.gz'],
      import_cat_cmd => 'zcat',
      import_timeout => 900,
      # mysql_exec_path => '/opt/rh/rh-myql57/root/bin',
    }
}
  php::fpm::pool{'nginx':
    user         => 'nginx',
    group        => 'nginx',
    listen_owner => 'nginx',
    listen_group => 'nginx',
    listen_mode  => '0660',
    listen       => '/var/run/php-fpm/nginx-fpm.sock',
  }
  archive { "/etc/nginx/YOURLS-${yourls_version}/shorten/index.php" :
    ensure  => present,
    source  => 's3://yourls-data/index.php',
    cleanup => false,
  }
  archive { "/etc/nginx/YOURLS-${yourls_version}/index.html" :
    ensure  => present,
    source  => 's3://yourls-data/index.html',
    cleanup => false,
  }
  archive { '/etc/pki/tls/certs/ls.st.current.crt' :
    ensure  => present,
    source  => 's3://yourls-data/ls.st.current.crt',
    cleanup => false,
  }
  archive { '/etc/pki/tls/certs/ls.st.current.key' :
    ensure  => present,
    source  => 's3://yourls-data/ls.st.current.key',
    cleanup => false,
  }
  archive { "/etc/nginx/YOURLS-${yourls_version}/yourls-logo.png":
    ensure  => present,
    source  => 's3://yourls-data/yourls-logo.png',
    cleanup => false,
  }
  # archive { "/etc/nginx/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
  #   ensure  => present,
  #   source  => 's3://yourls-data/Telescope_Front-470.jpg',
  #   cleanup => false,
  # }

  archive { "/etc/nginx/YOURLS-${yourls_version}/yourls-logo.png":
    ensure  => present,
    source  => 'https://lsst.org/Wht-Logo-web_0.png',
    cleanup => false,
  }


}
