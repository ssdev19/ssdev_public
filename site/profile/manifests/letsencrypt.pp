# Letsencrypt
# @param email_hide 
class profile::letsencrypt ( Sensitive[String]
  $email_hide,
) {
  $host = $facts['networking']['hostname']
  $fqdn = $facts['networking']['fqdn']
  # $email = lookup('email')
  include epel
  class { 'letsencrypt::plugin::dns_route53':
    manage_package => true,
  }
  class { 'letsencrypt':
    config            => {
      email  => $email_hide.unwrap,
      # server => 'https://acme-v02.api.letsencrypt.org/directory',
      server => 'https://acme-staging-v02.api.letsencrypt.org/directory',
    },
    # renew_cron_ensure => 'present',
  }
  letsencrypt::certonly { $host:
    # ensure      => 'absent',
    domains     => [$fqdn],
    # config_dir  => '/etc/ssl/certs/graylog/',
    # manage_cron          => true,
    # cron_hour            => [0,12],
    # cron_minute          => '30',
    # cron_before_command  => 'service graylog-server stop',
    # cron_success_command => '/bin/systemctl reload graylog-server.service',
    # suppress_cron_output => true,
  }
}
