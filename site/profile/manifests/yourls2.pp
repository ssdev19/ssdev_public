class profile::yourls2 ( String

$yourls_version,
$yourls_site,


){
  # include nginx
  include mysql::server
  # include '::php'
  # include '::php::globals'

  Package { [ 'openldap-devel', 'make', 'yum-utils' ]:
    ensure => installed,
  }
$yourls_user_passwords = lookup('yourls_user_passwords')
$yourls_db_pass = lookup('yourls_db_pass')
$yourls_db_user = lookup('yourls_db_user')
$yourls_db_name = lookup('yourls_db_name')
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
      grant          => ['SELECT', 'UPDATE'],
      sql            => ['/tmp/mysql-db-yourls.gz'],
      import_cat_cmd => 'zcat',
      import_timeout => 900,
      # mysql_exec_path => '/opt/rh/rh-myql57/root/bin',
    }
}


    archive { '/tmp/nginx-1.22.1.tar.gz':
      ensure       => present,
      source       => 'http://nginx.org/download/nginx-1.22.1.tar.gz',
      extract_path => '/tmp/',
      extract      => true,
      provider     => 'wget',
      cleanup      => true,
    }

    vcsrepo { '/tmp/nginx-1.22.1/nginx-auth-ldap':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
      user     => 'root',
    }
    exec {'compile':
      path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
      cwd      => '/tmp/nginx-1.22.1/',
      provider => shell,
      command  => './configure  --user=nginx --group=nginx --add-module=./nginx-auth-ldap; make install',
    }
# Creates nginx service in  /etc/systemd/system/nginx.service
$mainpid = lookup('mainpid')
  $nginx_service = @("EOT")
    [Unit]
    Description=The nginx HTTP and reverse proxy server
    After=network.target remote-fs.target nss-lookup.target

    [Service]
    Type=forking
    PIDFile=/run/nginx.pid
    # Nginx will fail to start if /run/nginx.pid already exists but has the wrong
    # SELinux context. This might happen when running `nginx -t` from the cmdline.
    # https://bugzilla.redhat.com/show_bug.cgi?id=1268621
    ExecStartPre=/usr/bin/rm -f /run/nginx.pid
    ExecStartPre=/usr/local/nginx/sbin/nginx -t
    ExecStart=/usr/local/nginx/sbin/nginx
    ExecReload=/bin/kill -s HUP "${mainpid}"
    KillSignal=SIGQUIT
    TimeoutStopSec=5
    KillMode=process
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
    | EOT
# 
  systemd::unit_file { 'nginx.service':
    content => "${nginx_service}",
    mode => '0664',
  }
  -> service { 'nginx':
  # subscribe => nginx::Instance['default'],
  ensure    => 'running',
  enable    => true,
  }
}
