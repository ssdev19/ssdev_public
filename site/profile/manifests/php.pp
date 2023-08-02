# php
class profile::php {
  Package { [ 'openldap-devel', 'make', 'yum-utils', 'epel-release' ]:
    ensure => installed,
  }
class { '::php::globals':
  php_version => '7.4',
  config_root => '/etc/php/7.4',
}
  -> class { '::php':
      manage_repos => true
    }
}
