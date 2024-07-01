# ots
class profile::ots {
  include '::gnupg'
  include ::scl
  include 'yum'
  # include rvm

# yum::config { 'powertools':
#   ensure  => present,
#   enabled => true,
# }
  $secret = lookup('secret')
  $redis_pwd = lookup('redis_pwd')
  class { 'rvm': }

  rvm_system_ruby {
    'ruby-3.3.3':
      ensure      => 'present',
      default_use => true,
      # build_opts  => ['--binary'],
      ;
    'ruby-3.1.1':
      ensure      => 'present',
      default_use => false;
  }

  # class { 'onetimesecret':
  #   version        => 'e1156b1f8ab98322a898ee4defd1c3f0adb9b5d3', # e858f1edde6cc6af7ef75aa45f2bb9f9b0f0ecf5
  #   install_dir    => '/opt',
  #   symlink_name   => '/opt/onetimesecret',
  #   secret         => $secret,
  #   redis_password => $redis_pwd,
  #   redis_options  => {
  #     maxmemory => '2gb',
  #   },
  # }
# ::scl::collection { 'Powertools':
#   enable => true,
# }
}
