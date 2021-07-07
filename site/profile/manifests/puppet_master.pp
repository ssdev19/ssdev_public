# puppet master config
class profile::puppet_master {
  # The toml gem is required for grafana ldap.
  # Be sure puppetserver service is restarted after the first run.
    package { 'toml':
      ensure   => present,
      provider => 'puppetserver_gem',
    }
  }
