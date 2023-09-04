# ots
class profile::ots {
include ::scl
include 'yum'


# yum::config { 'powertools':
#   ensure  => present,
#   enabled => true,
# }
$secret = lookup('secret')
$redis_pwd = lookup('redis_pwd')

  rvm_system_ruby {
    'ruby-2.7':
      ensure      => 'present',
      default_use => true;
  }

    class { 'onetimesecret':
      version        => 'e858f1edde6cc6af7ef75aa45f2bb9f9b0f0ecf5', # e858f1edde6cc6af7ef75aa45f2bb9f9b0f0ecf5
      # install_dir    => '/opt',
      # symlink_name   => '/opt/onetimesecret',
      secret         => $secret,
      redis_password => $redis_pwd,
      redis_options  => {
        maxmemory => '2gb',
      },
    }

# ::scl::collection { 'Powertools':
#   enable => true,
# }

}
