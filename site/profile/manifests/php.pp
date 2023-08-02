# php
class profile::php {

class { '::php::globals':
  php_version => '8.1',
  config_root => '/etc/php/8.1',
}
  -> class { '::php':
      manage_repos => true
    }
}
