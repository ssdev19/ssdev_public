# webserver
class profile::webserver {

include mysql::server
# PHP version
class { 'apache':
}
include ::php
# class { '::php::globals':
#   php_version => '7.2.34',
#   config_root => '/etc/php/7.0',
# }
# class { '::php':
#   manage_repos => true
# }
}

