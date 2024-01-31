# puppet master config
class profile::puppet_master3 {
  include r10k
  # include foreman
  # include foreman::repo
  # include foreman::plugin::puppet
  # include foreman::plugin::remote_execution
  # include foreman_proxy::plugin::remote_execution::script
  # include foreman::plugin::tasks
  # include foreman::plugin::templates
  # include foreman_proxy
  # include foreman_proxy::plugin::remote_execution::script
  # include puppet
  file { '/etc/puppetlabs/puppet/eyaml' :
    ensure  => directory,
  }
  class { 'puppet':
    server              => true,
    server_reports      => 'puppetdb,foreman',
    server_storeconfigs => true,
  }
  include puppetdb
  class { 'puppet::server::puppetdb':
    server => 'mypuppetdb.example.com',
  }
}
