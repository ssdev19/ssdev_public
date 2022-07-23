# Letsencrypt
class profile::letsencrypt {
  $host = $facts['networking']['hostname']
  $fqdn = $facts['networking']['fqdn']
letsencrypt::certonly { $host:
  domains     => [$fqdn],
  manage_cron => true,
}
}
