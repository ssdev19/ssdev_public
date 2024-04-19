# php
class profile::php {
  # Package { [ 'openldap-devel', 'make', 'yum-utils', 'epel-release' ]:
  #   ensure => installed,
  # }
    # include '::php'
  class { 'php::repo::redhat':
    yum_repo => 'remi_php81'
  }
  # class { '::php::globals':
  #   php_version => '8.0',
  #   # config_root => '/etc/php/8.0',
  # }
  # -> class { '::php':
  #     manage_repos => true
  #   }

  # class { 'php::packages':
  #   ensure => '8.2.8',
  #   manage_repos => true,
  #   # config_root => '/etc/php/8.1',
  # }
  # -> class { '::php':
  #     # manage_repos => true,
  #     # yum_repo     => 'remi_php81'
  #   }
}
