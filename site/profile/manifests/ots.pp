# ots
class profile::ots {
include ::scl

$secret = lookup('secret')
$redis_pwd = lookup('redis_pwd')
    class { 'onetimesecret':
      version        => 'v0.11.0',
      secret         => $secret,
      redis_password => $redis_pwd,
    }

::scl::collection { 'libyaml-devel':
  enable => true,
}

}
