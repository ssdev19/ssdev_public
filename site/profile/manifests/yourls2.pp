class profile::yourls2 ( String
# $ sudo yum module reset nginx
# $ sudo yum module enable nginx:1.16
# ## verify it version set to 1.22 ##
# $ sudo yum module list nginx
$yourls_version,
$yourls_site,


){
  include nginx
  include mysql::server
  # include '::php'
  # include '::php::globals'

  Package { [ 'openldap-devel', 'make', 'yum-utils', 'epel-release' ]:
    ensure => installed,
  }
$yourls_user_passwords = lookup('yourls_user_passwords')
$yourls_db_pass = lookup('yourls_db_pass')
$yourls_db_user = lookup('yourls_db_user')
$yourls_db_name = lookup('yourls_db_name')
$phpinfo = lookup ('phpinfo')
$phpinfo2 = lookup ('phpinfo2')

  archive { '/tmp/mysql-db-yourls.gz' :
    ensure  => present,
    source  => 's3://yourls-data/yourls/20230806030001-mysql-db-yourls.gz',
    cleanup => false,
  }
  # if $::yourls_db  {
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
# }
  unless $::nginx_conf  {
      archive { '/usr/src/nginx-1.24.0.tar.gz':
        ensure       => present,
        source       => 'http://nginx.org/download/nginx-1.24.0.tar.gz',
        extract_path => '/usr/src',
        extract      => true,
        provider     => 'wget',
        cleanup      => false,
      }

      vcsrepo { '/usr/src/nginx-1.24.0/nginx-auth-ldap':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
        user     => 'root',
      }

  }
}
