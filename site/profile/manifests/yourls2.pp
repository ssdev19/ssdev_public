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
    source  => 's3://yourls-data/yourls/20230728030002-mysql-db-yourls.gz',
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
  file { '/etc/nginx/YOURLS':
    ensure => 'link',
    target => "/etc/nginx/YOURLS-${yourls_version}",
  }
    archive { "/tmp/yourls-${yourls_version}.tar.gz":
      ensure       => present,
      source       => "https://github.com/YOURLS/YOURLS/archive/refs/tags/${yourls_version}.tar.gz",
      extract_path => '/etc/nginx',
      extract      => true,
      provider     => 'wget',
      cleanup      => false,
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/shorten":
    ensure => directory,
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
  archive { '/etc/nginx/conf.d/yourls.conf' :
    ensure  => present,
    source  => 's3://yourls-data/yourls_config_new.txt',
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

}