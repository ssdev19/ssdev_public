# ots
class profile::ots {
include ::scl

$secret = lookup('secret')
$redis_pwd = lookup('redis_pwd')
    class { 'onetimesecret':
      version        => 'fc355c1c2931de0aaca3a99290a33f776bbcd257',
      install_dir    => '/opt',
      symlink_name   => '/opt/onetimesecret',
      secret         => $secret,
      redis_password => $redis_pwd,
    }

# ::scl::collection { 'Powertools':
#   enable => true,
# }

}
