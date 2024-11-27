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
  # file { '/opt/onetimesecret' :
  #   ensure  => directory,
  #   # owner   => 'ots',
  #   # grubyroup   => 'ots',
  # }
# Manually install ruby:  rvm install "ruby-2.6.0"
# Set it to default:  rvm 2.7.8 --default
# gem update --system 3.2.3
# gem install bundler:2.4.12
# bundle update --bundler
# Reboot needed after installation perhaps a few times
  # rvm_system_ruby {
  #   'ruby-3.2.5':
  #     ensure      => 'present',
  #     default_use => true,
  #     # build_opts  => ['--binary'],
  #     ;
  #   # 'ruby-2.5.9':
  #   #   ensure      => 'present',
  #   #   default_use => false;
  # }
  # rvm_gemset {
  #   'ruby-3.2.5@testing':
  #     ensure  => present,
  #     require => Rvm_system_ruby['ruby-3.2.5'];
  # }
  # rvm_gem {
  #   'bundler':
  #     ensure       => latest,
  #     name         => 'bundler',
  #     ruby_version => 'ruby-3.2.2',
  #     require      => Rvm_system_ruby['ruby-3.2.2'];
  # }
  # vcsrepo { "/opt/onetimesecret":
  #   ensure   => present,
  #   provider => git,
  #   source   => 'https://github.com/onetimesecret/onetimesecret.git',
  #   user     => 'root',
  # }
  class { 'onetimesecret':
    version        => 'v0.9.2',
    secret         => 'SomeHardToGuessRandomCharacters',
    redis_password => 'AnotherGoodPassword',
  }
  # class { 'onetimesecret':
  #   version        => '945bb2a3cb43213f71e67abd0fa561267699d0eb',  #'e858f1edde6cc6af7ef75aa45f2bb9f9b0f0ecf5', #  e1156b1f8ab98322a898ee4defd1c3f0adb9b5d3
  #   install_dir    => '/opt',
  #   symlink_name   => '/opt/onetimesecret',
  #   secret         => $secret,
  #   redis_password => $redis_pwd,
  #   redis_options  => {
  #     maxmemory => '2gb',
  #   },
  # }
  # file { '/opt/onetimesecret-v0.14.0':
  #   ensure => link,
  #   target => '/opt/onetimesecret-0.14.0',
  #   # require => Class['graylog-server'],
  # }
# ::scl::collection { 'Powertools':
#   enable => true,
# }
}
