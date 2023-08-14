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
  unless $::nginx_conf  {
      archive { '/usr/src/nginx-1.22.1.tar.gz':
        ensure       => present,
        source       => 'http://nginx.org/download/nginx-1.22.1.tar.gz',
        extract_path => '/usr/src',
        extract      => true,
        provider     => 'wget',
        cleanup      => false,
      }

      vcsrepo { '/usr/src/nginx-1.22.1/nginx-auth-ldap':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
        user     => 'root',
      }

  }
  unless $::yourls_config  {
    exec {'compile':
      path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
      cwd      => '/usr/src/nginx-1.22.1/',
      provider => shell,
      command  => './configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-stream_ssl_preread_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_auth_request_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_realip_module --with-stream_ssl_module --add-module=/usr/src/nginx-1.22.1/nginx-auth-ldap; make install',
    }
    vcsrepo { "/etc/nginx/YOURLS-${yourls_version}":
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
    # archive { '/tmp/config.php' :
    #   ensure  => present,
    #   source  => 's3://yourls-data/config.php',
    #   cleanup => false,
    # }
    # file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
    #   ensure  => present,
    #   source  => '/tmp/config.php',
    #   replace => 'yes',
    # }
      file { "/etc/nginx/YOURLS-${yourls_version}/shorten":
      ensure => directory,
    }
  }
file { '/etc/nginx/YOURLS':
  ensure => 'link',
  target => "/etc/nginx/YOURLS-${yourls_version}",
}

  archive { '/tmp/mysql-db-yourls.gz' :
    ensure  => present,
    source  => 's3://yourls-data/yourls/20230806030001-mysql-db-yourls.gz',
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
  archive { '/etc/nginx/conf.d/yourls.conf' :
    ensure  => present,
    source  => 's3://yourls-data/yourls_config_new.txt',
    cleanup => false,
  }
  archive { "/etc/nginx/YOURLS-${yourls_version}/user/config.php" :
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
  archive { "/etc/nginx/YOURLS-${yourls_version}/.htaccess" :
    ensure  => present,
    source  => 's3://yourls-data/htaccess',
    cleanup => false,
  }
  archive { '/etc/nginx/nginx.conf' :
    ensure  => present,
    source  => 's3://yourls-data/nginx_conf.txt',
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

  archive { "/etc/nginx/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
    ensure  => present,
    source  => 'https://www.lsst.org/sites/default/files/Wht-Logo-web_0.png',
    cleanup => false,
  }
  $phpinfo = lookup ('phpinfo')
  file { "/etc/nginx/YOURLS-${yourls_version}/phpinfo.php" :
    ensure  => file,
    content => $phpinfo,
  }
  archive { '/etc/php-fpm.d/www.conf' :
    ensure  => present,
    source  => 's3://yourls-data/www_conf_new',
    cleanup => false,
  }

# Creates nginx service in  /etc/systemd/system/nginx.service
# Sometimes the server needs to be rebooted after the service creation.
# $mainpid = '$MAINPID' #lookup('mainpid')
#   $nginx_service = @("EOT")
#     [Unit]
#     Description=The nginx HTTP and reverse proxy server
#     After=network.target remote-fs.target nss-lookup.target

#     [Service]
#     Type=forking
#     PIDFile=/var/run/nginx.pid
#     # Nginx will fail to start if /run/nginx.pid already exists but has the wrong
#     # SELinux context. This might happen when running `nginx -t` from the cmdline.
#     # https://bugzilla.redhat.com/show_bug.cgi?id=1268621
#     ExecStartPre=/usr/bin/rm -f /var/run/nginx.pid
#     ExecStartPre=/usr/sbin/nginx -t
#     ExecStart=/usr/sbin/nginx
#     ExecReload=/bin/kill -s HUP ${mainpid}
#     KillSignal=SIGQUIT
#     TimeoutStopSec=5
#     KillMode=process
#     PrivateTmp=true

#     [Install]
#     WantedBy=multi-user.target
#     | EOT
# # 
#   systemd::unit_file { 'nginx.service':
#     content => "${nginx_service}",
#     mode => '0664',
#   }
#   -> service { 'nginx':
#   # subscribe => nginx::Instance['default'],
#   enable    => true,
#   ensure    => 'running',
#   }
  file {
    '/etc/systemd/system/nginx.service.d':
      ensure => directory,
  }
  unless $::nginx_pid  {
    exec {'fix_nginx.pid_error':
      path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
      provider => shell,
      command  => 'printf "[Service]\\nExecStartPost=/bin/sleep 0.1\\n" > /etc/systemd/system/nginx.service.d/override.conf; systemctl daemon-reload; systemctl restart nginx ',
    }
  }

}
