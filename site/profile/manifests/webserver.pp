# webserver
class profile::webserver {

include mysql::server
# PHP version
class { 'apache':
}
  Package { [ 'epel-release', 'yum-utils', 'http://rpms.remirepo.net/enterprise/remi-release-7.rpm' ]:
  ensure => installed,
  }
include '::php'
# class { '::php::globals':
#   php_version => '7.2.34',
#   config_root => '/etc/php/7.0',
# }
# class { '::php':
#   manage_repos => true
# }
}
