# puppet master config
class profile::puppet_master {
  include r10k
  # The toml gem is required for grafana ldap.
  # Be sure puppetserver service is restarted after the first run.
  package { 'toml':
    ensure   => present,
    provider => 'puppetserver_gem',
  }

#   if ($facts['test_fact'] == true ) {
#     notify { "Path exist": }
#   } else {
#     notify{ "File does not existss": }
#   }
#   if $facts['os']['family'] == 'RedHat' {
#     notify { "It is Centos": }
#   } else {
#     notify { "This is not centos": }
#   }
}
