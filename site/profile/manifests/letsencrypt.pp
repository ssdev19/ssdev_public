# Letsencrypt
# @param email_hide 
class profile::letsencrypt ( Sensitive[String]
  $email_hide,
) {
  $host = $facts['networking']['hostname']
  $fqdn = $facts['networking']['fqdn']
  # $email = lookup('email')
  include epel
  class { 'letsencrypt':
    config            => {
      email  => $email_hide.unwrap,
      # server => 'https://acme-v02.api.letsencrypt.org/directory',
      server => 'https://acme-staging-v02.api.letsencrypt.org/directory',
    },
    # renew_cron_ensure => 'present',
  }
  class { 'letsencrypt::plugin::dns_route53':
    manage_package => true,
  }
  yum::versionlock { 'python-s3transfer':
    ensure  => present,
    version => '0.1.13',
    release => '1.el7.0.1',
    arch    => 'noarch',
    before  => [
      Class['letsencrypt::plugin::dns_route53'],
      Package['python-s3transfer'],
    ],
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
