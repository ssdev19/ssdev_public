# Letsencrypt
class profile::letsencrypt {
  $host = $facts['networking']['hostname']
  $fqdn = $facts['networking']['fqdn']
  $email = lookup('email')
class { 'letsencrypt':
  config => {
    email  => $email,
    server => 'https://acme-v01.api.letsencrypt.org/directory',
  }
}
letsencrypt::certonly { $host:
  domains     => [$fqdn],
  config_dir  => '/etc/ssl/graylog/',
  # manage_cron          => true,
  # cron_hour            => [0,12],
  # cron_minute          => '30',
  # cron_before_command  => 'service graylog-server stop',
  # cron_success_command => '/bin/systemctl reload graylog-server.service',
  # suppress_cron_output => true,
}
}
