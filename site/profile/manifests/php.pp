# php
class profile::php {
  Package { [ 'openldap-devel', 'make', 'yum-utils', 'epel-release' ]:
    ensure => installed,
  }
  class { '::php::globals':
    php_version => '8.1',
    config_root => '/etc/php/8.1',
  }
  -> class { '::php':
      manage_repos => true,
      # yum_repo     => 'remi_php81'
    }
}
