# ots
class profile::ots {
include ::scl

$secret = lookup('secret')
$redis_pwd = lookup('redis_pwd')
    class { 'onetimesecret':
      version        => '0.10.1',
      install_dir    => '/opt',
      secret         => $secret,
      redis_password => $redis_pwd,
    }

# ::scl::collection { 'Powertools':
#   enable => true,
# }

}
