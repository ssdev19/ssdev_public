# webserver
class profile::webserver {
include nginx
# include mysql::server

  # mysql::db { 'mydb':
  #   user     => 'mydbuser',
  #   password => 'changeme',
  #   host     => 'localhost',
  #   grant    => ['SELECT', 'UPDATE'],
  # }
  # class { 'apache':
  # default_vhost => false,
  # }
  # apache::vhost { 'test1.us.lsst.org':
  # port    => '80',
  # docroot => '/var/www/vhost',
  # }
# Below this line they only need to run once.  They can be commented out after first run.
  # Package { [ 'php-drush-drush', 'epel-release', 'yum-utils', 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm' ]: #, 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm'
  # ensure => installed,
  # }
  # exec { 'yum-config-manager':
  #   command => 'yum-config-manager --enable remi-php74',
  #   path    => [ '/usr/local/bin/', '/bin/' ],  # alternative syntax
  # }
# PHP version
# include '::php'
  # class { '::php::globals':
  #   php_version => '7.4.24',
  #   config_root => '/etc/php/7.0',
  # }
}
