# webserver config.  SELinux should be disabled until rules are configured.
class profile::webserver {
  class { 'mysql::server':
    root_password           => 'rootpwd',
    remove_default_accounts => true,
    restart                 => true,
  }
  mysql::db { 'yourlsdb':
    user     => 'yourlsdbuser',
    password => 'yourlsdbpasswd',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
  }
include nginx
include selinux
# include mysql::server

# Below this line they only need to run once.  They can be commented out after first run.
  # Package { [ 'php-drush-drush', 'epel-release', 'yum-utils', 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm' ]:
  # ensure => installed,
  # }
  # exec { 'yum-config-manager':
  #   command => 'yum-config-manager --enable remi-php73',
  #   path    => [ '/usr/local/bin/', '/bin/' ],  # alternative syntax
  # }
# PHP version
# include '::php'
  class { '::php::globals':
    php_version => '7.3.31',
    # config_root => '/etc/php/7.0',
  }
  -> class { '::php':
    manage_repos => false,
    fpm_user     => 'nginx',
    fpm_group    => 'nginx',
  }
#   /etc/nginx/YOURLS/user/config.php #contains config settings for the YOURLS app to connect to its mysql server, time settings, 
# and the webserver. It also stores local users authorized to login to the yourls admin page.
# /etc/nginx/conf.d/yourls.conf #nginx conf file for YOURLS website and webpages.
# /etc/php-fpm.d/*.conf #php-fpm must be configured properly and running for YOURLS to render properly.
# nginx conf files:
# /etc/nginx/nginx.conf
# /etc/nginx/conf.d/yourls.conf
  file{ '/etc/nginx/YOURLS':
  ensure => directory
  }
  vcsrepo { '/etc/nginx/YOURLS':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/AnonSS/YOURLS.git',
  }
  exec { 'chown /etc/nginx/YOURLS':
    command => 'chown -R nginx: /etc/nginx/YOURLS',
    path    => [ '/usr/local/bin/', '/bin/' ],
  }
}
