# URL Shortener.  Use dnf install nginx instead of the module as it needs to be recompiled.
# @param yourls_db_pass_hide
#  String DB password
# @param yourls_db_user_hide
#  Accepts DB username
# @param yourls_version
#  Accepts yourls_version
# @param nginx_version
#  Accepts nginx_version
class profile::yourls2 (
  Sensitive[String] $yourls_db_pass_hide,
  Sensitive[String] $yourls_db_user_hide,
  String $yourls_version,
  String $nginx_version,
) {
  include mysql::server

  Package {['openldap-devel', 'make', 'yum-utils', 'pcre-devel', 'epel-release']:
    ensure => installed,
  }
  archive { "/usr/src/YOURLS-${yourls_version}.tar.gz":
    ensure       => present,
    source       => "https://github.com/YOURLS/YOURLS/archive/refs/tags/${yourls_version}.tar.gz",
    extract_path => '/etc/nginx',
    extract      => true,
    provider     => 'wget',
    cleanup      => false,
  }
  unless $::nginx_source {
    archive { "/usr/src/nginx-${nginx_version}.tar.gz":
      ensure       => present,
      source       => "http://nginx.org/download/nginx-${nginx_version}.tar.gz",
      extract_path => '/usr/src',
      extract      => true,
      provider     => 'wget',
      cleanup      => false,
    }
    vcsrepo { "/usr/src/nginx-${nginx_version}/nginx-auth-ldap":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
      user     => 'root',
    }
    # vcsrepo { "/etc/nginx/YOURLS-${yourls_version}":
    #   ensure   => present,
    #   provider => git,
    #   source   => 'https://github.com/YOURLS/YOURLS.git',
    #   user     => 'root',
    # }
    archive { '/tmp/mysql-db-yourls.gz' :
      ensure  => present,
      source  => 's3://urlshortener-data/mysql-db-yourls-latest.gz',
      cleanup => true,
    }
    $yourls_db_name = lookup('yourls_db_name')
    mysql::db { $yourls_db_name:
      user           => $yourls_db_user_hide.unwrap,
      password       => $yourls_db_pass_hide.unwrap,
      host           => 'localhost',
      grant          => ['ALL'],
      sql            => ['/tmp/mysql-db-yourls.gz'],
      import_cat_cmd => 'zcat',
      import_timeout => 900,
    }
  }

  archive { '/etc/pki/tls/certs/ls.st.current.crt' :
    ensure  => present,
    source  => 's3://urlshortener-data/ls.st.current.crt',
    cleanup => false,
  }
  archive { '/etc/pki/tls/certs/ls.st.current.key' :
    ensure  => present,
    source  => 's3://urlshortener-data/ls.st.current.key',
    cleanup => false,
  }
  archive { "/etc/nginx/YOURLS-${yourls_version}/yourls-logo.png":
    ensure  => present,
    source  => 's3://urlshortener-data/yourls-logo.png',
    cleanup => false,
  }
  # archive { "/etc/nginx/YOURLS-${yourls_version}/yourls-logo.png":
  #   ensure  => present,
  #   source  => 's3://urlshortener-data/Telescope_Front-470.jpg',
  #   cleanup => false,
  # }
  # archive { "/etc/nginx/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
  #   ensure  => present,
  #   source  => 's3://urlshortener-data/Telescope_Front-470.jpg',
  #   cleanup => false,
  # }
  # archive { "/etc/nginx/YOURLS-${yourls_version}/images/yourls-logo.svg":
  #   ensure  => present,
  #   source  => 's3://urlshortener-data/url-shortener.jpg',
  #   cleanup => false,
  # }

  archive { "/etc/nginx/YOURLS-${yourls_version}/Rubin_logo.jpg":
    ensure  => present,
    source  => 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQY1IYVnzXBxZiG_eIDby1A8boVxvnu3ORcI4BOUN_2Ew&s',
    cleanup => false,
  }
  $phpinfo = lookup ('phpinfo')
  file { "/etc/nginx/YOURLS-${yourls_version}/phpinfo.php" :
    ensure  => file,
    content => $phpinfo,
  }
  file {
    '/etc/systemd/system/nginx.service.d':
      ensure => directory,
  }
  unless $::nginx_pid {
    exec { 'fix_nginx.pid_error':
      path     => ['/usr/bin', '/bin', '/usr/sbin'],
      provider => shell,
      command  => 'printf "[Service]\\nExecStartPost=/bin/sleep 0.1\\n" > /etc/systemd/system/nginx.service.d/override.conf; systemctl daemon-reload; systemctl restart nginx ',
    }
  }
  # Compile nginx
  unless $::yourls_config {
    archive { '/tmp/yourls_config.zip' :
      ensure       => present,
      source       => 's3://urlshortener-data/yourls_config.zip',
      cleanup      => false,
      extract      => true,
      extract_path => '/tmp',
    }
    exec { 'compile':
      path     => ['/usr/bin', '/bin', '/usr/sbin'],
      cwd      => "/usr/src/nginx-${nginx_version}/",
      provider => shell,
      command  => "./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-stream_ssl_preread_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_auth_request_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_realip_module --with-stream_ssl_module --add-module=/usr/src/nginx-${nginx_version}/nginx-auth-ldap; make; make install",
      timeout  => 900,
      # onlyif   => 'test -e /usr/src/nginx-1.22.1/configure'
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/shorten/index.php":
      ensure  => file,
      source  => '/tmp/index.php',
      replace => 'yes',
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/index.html":
      ensure  => file,
      source  => '/tmp/index.html',
      replace => 'yes',
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
      ensure  => file,
      source  => '/tmp/config.php',
      replace => 'yes',
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/.htaccess":
      ensure  => file,
      source  => '/tmp/htaccess',
      replace => 'yes',
    }
    file { '/etc/nginx/conf.d/yourls.conf':
      ensure  => file,
      source  => '/tmp/yourls_config_new.txt',
      replace => 'yes',
    }
    file { '/etc/nginx/nginx.conf':
      ensure  => file,
      source  => '/tmp/nginx_conf.txt',
      replace => 'yes',
    }
# Installs plugins.  Need to be activated in GUI
    file {
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/mass-remove-links":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/mass-remove-links/plugin.php":
        ensure => file,
        source => '/tmp/mass-remove-links-plugin.php',
        ;

      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/preview-url":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/preview-url/plugin.php":
        ensure => file,
        source => '/tmp/preview-url-plugin.php'
        ;

      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/show-plugin":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/show-plugin/plugin.php":
        ensure => file,
        source => '/tmp/show-plugin-plugin.php'
        ;

      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/yourls-preview-url-with-qrcode":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/yourls-preview-url-with-qrcode/plugin.php":
        ensure => file,
        source => '/tmp/yourls-preview-url-with-qrcode-plugin.php'
        ;
# Shorten directory
      "/etc/nginx/YOURLS-${yourls_version}/shorten":
        ensure => directory,
        ;
    }
  }
  file { '/etc/nginx/YOURLS':
    ensure => 'link',
    target => "/etc/nginx/YOURLS-${yourls_version}",
  }
  # $mariadb_root_pwd = lookup('mariadb_root_pwd')
# yumrepo { 'percona':
#   descr    => 'CentOS $releasever - Percona',
#   baseurl  => 'http://repo.percona.com/release/$releasever/RPMS/$basearch',
#   gpgkey   => 'https://www.percona.com/downloads/RPM-GPG-KEY-percona https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
#   enabled  => 1,
#   gpgcheck => 1,
# }
# class { 'mysql::server::backup':
#   backupuser          => $yourls_db_user_hide.unwrap,
#   backuppassword      => $yourls_db_pass_hide.unwrap,
#   provider            => 'mysqldump',
#   incremental_backups => false,
#   backupdir           => '/backups/dumps',
#   backuprotate        => 10,
#   execpath            => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
#   time                => ['0', '4'],
# }
# file { '/backups/nginx/oldest':
#   ensure  => directory,
#   recurse => true,
#   replace => false,
#   source  => ['/etc/nginx', '/etc/php'],
# }
# if $::phpinfo {
#   unless $::nginx_bk {
#     rsync::get { '/backups/nginx/earliest':
#       source    => '/etc/nginx/*',
#       copylinks => true,
#       # require => File['/nginx'],
#     }
#   }
# }
# rsync::put { '/backups/$(date +%F)-nginx':
#   # user    => 'root',
#   source  => '/etc/nginx/*',
# }
}
