# puppet master config
class profile::puppet_master {
  include r10k
  # The toml gem is required for grafana ldap.
  # Be sure puppetserver service is restarted after the first run.
    package { 'toml':
      ensure   => present,
      provider => 'puppetserver_gem',
    }
  archive { '/tmp/pingfederate11':
    ensure   => present,
    source   => 'https://auraastronomy-my.sharepoint.com/:f:/g/personal/rrichmond_aura-astronomy_org/Ety_d7IdJDdIgD1X4y5IrMABQ22ezhyRiPerGFOK8dwFGQ?e=kPtsWH',
    # provider => 'wget',
    cleanup  => false,
  }
}
