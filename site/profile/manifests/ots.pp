# ots
class profile::ots {

$secret = lookup('secret')
$redis_pwd = lookup('seredis_pwdcret')
    class { 'onetimesecret':
      version        => 'v0.11.0',
      secret         => $secret,
      redis_password => $redis_pwd,
    }
}
