# ots
class profile::ots {
include ::scl

$secret = lookup('secret')
$redis_pwd = lookup('redis_pwd')
    class { 'onetimesecret':
      version        => 'e1156b1f8ab98322a898ee4defd1c3f0adb9b5d3',
      install_dir    => '/opt',
      symlink_name   => '/opt/onetimesecret',
      secret         => $secret,
      redis_password => $redis_pwd,
    }

# ::scl::collection { 'Powertools':
#   enable => true,
# }

}
