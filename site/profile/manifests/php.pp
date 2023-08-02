# php
class profile::php {

class { '::php::globals':
  php_version => '8.0',
  config_root => '/etc/php/8.0',
}
  -> class { '::php':
      manage_repos => true
    }
}
