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
  version => 8,
}
class { 'elasticsearch':
  ensure => 'absent'
}

# class { 'elasticsearch':
#   version     => '8.3.2',
#   # repo_version => '8.x',
#   # ensure => 'absent',
#   manage_repo => true,
#   jvm_options => [
#   '-Xms1g',
#   '-Xmx1g'
#   ]
# }
# Support for elasticsearch multi instance has been remove so cannot user: elasticsearch::instance
}
