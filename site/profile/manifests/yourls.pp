# 
class profile::yourls ( String

$yourls_version,
$yourls_site,


){
  # include nginx
  include mysql::server
  # include '::php'
  # include '::php::globals'

# class { '::php::globals':
#   php_version => '7.3',
#   config_root => '/etc/php/',
# }
# -> class { '::php':
#     manage_repos => true,
#     ensure       => '7.3.27',
# }

  Package { [ 'openldap-devel', 'make', 'yum-utils', 'pcre-devel' ]:
    ensure => installed,
  }
$yourls_user_passwords = lookup('yourls_user_passwords')
$yourls_db_pass = lookup('yourls_db_pass')
$yourls_db_user = lookup('yourls_db_user')
$yourls_db_name = lookup('yourls_db_name')

  unless $::yourls_config  {
    vcsrepo { "/var/www/html/YOURLS-${yourls_version}":
      ensure   => present,
      provider => git,
      source   => "https://github.com/YOURLS/YOURLS.git",
      user     => 'root',
    }
  # archive { "/tmp/yourls-${yourls_version}.tar.gz":
  #     ensure       => present,
  #     source       => "https://github.com/YOURLS/YOURLS/archive/refs/tags/${yourls_version}.tar.gz",
  #     extract_path => '/etc/nginx',
  #     extract      => true,
  #     provider     => 'wget',
  #     cleanup      => false,
  #   }
    archive { '/tmp/config.php' :
      ensure  => present,
      source  => 's3://yourls-data/config.php',
      cleanup => false,
    }
    file { "/var/www/html/YOURLS-${yourls_version}/user/config.php":
      ensure  => present,
      source  => '/tmp/config.php',
      replace => 'yes',
    }
      file { "/var/www/html/YOURLS-${yourls_version}/shorten":
      ensure => directory,
    }
    archive { '/tmp/nginx-1.14.1.tar.gz':
      ensure       => present,
      source       => 'http://nginx.org/download/nginx-1.14.1.tar.gz',
      extract_path => '/tmp/',
      extract      => true,
      provider     => 'wget',
      cleanup      => true,
    }

    vcsrepo { '/tmp/nginx-1.14.1/nginx-auth-ldap':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
      user     => 'root',
    }
  }
file { '/var/www/html/YOURLS':
  ensure => 'link',
  target => "/var/www/html/YOURLS-${yourls_version}",
}

  # exec {'compile':
  #   path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
  #   cwd      => '/tmp/nginx-1.24.0/',
  #   provider => shell,
  #   command  => './configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=nginx --group=nginx --add-module=./nginx-auth-ldap',
  # }
  archive { '/tmp/mysql-db-yourls.gz' :
    ensure  => present,
    source  => 's3://yourls-data/yourls/20230728030002-mysql-db-yourls.gz',
    cleanup => false,
  }



  if $::yourls_db  {
    mysql::db { $yourls_db_name:
      user           => $yourls_db_user,
      password       => $yourls_db_pass,
      host           => 'localhost',
      grant          => ['ALL'],
      sql            => ['/tmp/mysql-db-yourls.gz'],
      import_cat_cmd => 'zcat',
      import_timeout => 900,
      # mysql_exec_path => '/opt/rh/rh-myql57/root/bin',
    }
}
  # php::fpm::pool{'nginx':
  #   user         => 'nginx',
  #   group        => 'nginx',
  #   listen_owner => 'nginx',
  #   listen_group => 'nginx',
  #   listen_mode  => '0660',
  #   listen       => '/var/run/php-fpm/nginx-fpm.sock',
  # }
  archive { "/var/www/html/YOURLS-${yourls_version}/shorten/index.php" :
    ensure  => present,
    source  => 's3://yourls-data/index.php',
    cleanup => false,
  }
  archive { "/var/www/html/YOURLS-${yourls_version}/index.html" :
    ensure  => present,
    source  => 's3://yourls-data/index.html',
    cleanup => false,
  }
  archive { '/etc/nginx/conf.d/yourls.conf' :
    ensure  => present,
    source  => 's3://yourls-data/yourls_config_new.txt',
    cleanup => false,
  }
  archive { "/var/www/html/YOURLS-${yourls_version}/user/config.php" :
    ensure  => present,
    source  => 's3://yourls-data/config.php',
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
  archive { '/etc/nginx/fastcgi.conf' :
    ensure  => present,
    source  => 's3://yourls-data/fastcgi.conf',
    cleanup => false,
  }
  archive { "/var/www/html/YOURLS-${yourls_version}/.htaccess" :
    ensure  => present,
    source  => 's3://yourls-data/htaccess',
    cleanup => false,
  }
  archive { "/var/www/html/YOURLS-${yourls_version}/yourls-logo.png":
    ensure  => present,
    source  => 's3://yourls-data/yourls-logo.png',
    cleanup => false,
  }
  # archive { "/etc/nginx/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
  #   ensure  => present,
  #   source  => 's3://yourls-data/Telescope_Front-470.jpg',
  #   cleanup => false,
  # }

  archive { "/var/www/html/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
    ensure  => present,
    source  => 'https://www.lsst.org/sites/default/files/Wht-Logo-web_0.png',
    cleanup => false,
  }
  $phpinfo = lookup ('phpinfo')
  file { '/usr/share/nginx/html/phpinfo.php' :
    ensure  => file,
    content => $phpinfo,
  }

}
