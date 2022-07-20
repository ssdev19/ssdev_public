# Graylog
class profile::graylog {
  include java
    file { '/etc/ssl/graylog':
      ensure => directory,
    }
class { 'mongodb::globals':
  manage_package_repo => true,
}
-> class { 'mongodb::server':
  bind_ip => ['127.0.0.1'],
}
class { 'elastic_stack::repo':
  version => 7,
}
# class { 'elasticsearch':
#   ensure => 'absent'
# }

class { 'elasticsearch':
  version     => '7.9.3',
  api_protocol            => 'http',
  api_host                => 'localhost',
  api_port                => 9200,
  api_timeout             => 10,
  api_basic_auth_username => undef,
  api_basic_auth_password => undef,
  api_ca_file             => undef,
  api_ca_path             => undef,
  validate_tls            => true,
  # repo_version => '8.x',
  # ensure => 'absent',
  manage_repo => true,
  jvm_options => [
  '-Xms1g',
  '-Xmx1g'
  ]
}
# Support for elasticsearch multi instance has been remove so cannot user: elasticsearch::instance
}
