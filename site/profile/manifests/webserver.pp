# webserver
class profile::webserver {
include nginx
# include mysql::server

# Below this line they only need to run once.  They can be commented out after first run.
  # Package { [ 'php-drush-drush', 'epel-release', 'yum-utils', 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm' ]: #, 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm'
  # ensure => installed,
  # }
  # exec { 'yum-config-manager':
  #   command => 'yum-config-manager --enable remi-php74',
  #   path    => [ '/usr/local/bin/', '/bin/' ],  # alternative syntax
  # }  # End comment out
# PHP version
# include '::php'
  class { '::php::globals':
    php_version => '7.4.24',
    config_root => '/etc/php/7.0',
  }
  -> class { '::php':
    fpm_user     => 'nginx',
    fpm_group    => 'nginx',
    manage_repos => true
  }
  php::fpm::pool { 'webserver2-ssdev':
  listen => 'webserver2-ssdev.us.lsst.org',
  }
#   /etc/nginx/YOURLS/user/config.php #contains config settings for the YOURLS app to connect to its mysql server, time settings, and the webserver. It also stores local users authorized to login to the yourls admin page.
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
