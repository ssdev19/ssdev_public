# Letsencrypt
class profile::letsencrypt {
  $host = $facts['networking']['hostname']
  $fqdn = $facts['networking']['fqdn']
letsencrypt::certonly { $host:
  ensure      => 'absent',
  domains     => [$fqdn],
  manage_cron => true,
}
}
