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
      server => 'https://acme-v02.api.letsencrypt.org/directory',
    },
    # renew_cron_ensure => 'present',
  }
  letsencrypt::certonly { $host:
    # ensure      => 'absent',
    domains     => ['lsst.org'],
    # config_dir  => '/etc/ssl/certs/graylog/',
    # manage_cron          => true,
    # cron_hour            => [0,12],
    # cron_minute          => '30',
    # cron_before_command  => 'service graylog-server stop',
    # cron_success_command => '/bin/systemctl reload graylog-server.service',
    # suppress_cron_output => true,
  }
}
