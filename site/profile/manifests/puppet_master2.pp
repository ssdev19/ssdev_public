# puppet master config
class profile::puppet_master2 {
  include r10k
  # The toml gem is required for grafana ldap.
  # Be sure puppetserver service is restarted after the first run.
    # package { 'toml':
    #   ensure   => present,
    #   provider => 'puppetserver_gem',
    # }
  # java_ks { 'puppetca:truststore':
  #   ensure       => latest,
  #   certificate  => '/etc/puppet/ssl/certs/ca.pem',
  #   target       => '/etc/activemq/broker.ts',
  #   password     => 'puppet',
  #   trustcacerts => true,
  # }
}
