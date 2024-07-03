# ots
class profile::ots {
  # include onetimesecret
  # include '::gnupg'
  # include ::scl
  include 'yum'
  # include redis
  include rvm

  # yum::config { 'powertools':
  #   ensure  => present,
  #   # enabled => true,
  # }
  $secret = lookup('secret')
  $redis_pwd = lookup('redis_pwd')
  # class { 'rvm': }
  # file { '/opt/onetimesecret-v0.14.0' :
  #   ensure  => directory,
  #   # owner   => 'ots',
  #   # group   => 'ots',
  # }
# Manually install ruby:  rvm install "ruby-2.6.0"
# Set it to default:  rvm 2.6.0 --default
# gem update --system 3.2.3
# Reboot needed after installation
  # rvm_system_ruby {
  #   'ruby-Ruby 2.6.0':
  #     ensure      => 'present',
  #     default_use => true,
  #     # build_opts  => ['--binary'],
  #     ;
  #   # 'ruby-3.3.3':
  #   #   ensure      => 'present',
  #   #   default_use => false;
  # }
  rvm_gem {
    'bundler':
      ensure       => latest,
      name         => 'bundler',
      ruby_version => 'ruby-2.6.0',
      require      => Rvm_system_ruby['ruby-2.6.0'];
  }
  class { 'onetimesecret':
    version        => 'v0.14.0',  #'e858f1edde6cc6af7ef75aa45f2bb9f9b0f0ecf5', #  e1156b1f8ab98322a898ee4defd1c3f0adb9b5d3
    install_dir    => '/opt',
    symlink_name   => '/opt/onetimesecret',
    secret         => $secret,
    redis_password => $redis_pwd,
    redis_options  => {
      maxmemory => '2gb',
    },
  }
  file { '/opt/onetimesecret-v0.14.0':
    ensure => link,
    target => '/opt/onetimesecret-0.14.0',
    # require => Class['graylog-server'],
  }
# ::scl::collection { 'Powertools':
#   enable => true,
# }
}
