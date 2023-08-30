# ots
class profile::ots {
include ::scl

    Package { [
    # 'devtoolset-8',
    'rh-ruby26-ruby-devel' ]:
    ensure => installed,
    }
$secret = lookup('secret')
$redis_pwd = lookup('redis_pwd')
    class { 'onetimesecret':
      version        => '0.11.0',
      secret         => $secret,
      redis_password => $redis_pwd,
    }

# ::scl::collection { 'Powertools':
#   enable => true,
# }

}
