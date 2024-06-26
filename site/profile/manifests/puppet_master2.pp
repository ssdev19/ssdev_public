# puppet master config
class profile::puppet_master2 {
  include r10k
  # include foreman
  # include foreman::cli
  # include foreman::compute::libvirt
  # include foreman::plugin::remote_execution
  # include foreman::plugin::tasks
  # include foreman_proxy
  # include foreman_proxy::plugin::dynflow
  # include foreman_proxy::plugin::remote_execution::ssh
  # include foreman::repo
  # include puppet
  #   Package { [
  #   'devtoolset-8',
  #   'rh-ruby27-ruby-devel' ]:
  #   ensure => installed,
  #   }
# Agent and puppetmaster:
# class { '::puppet': server => true }
  # The toml gem is required for grafana ldap.
  # Be sure puppetserver service is restarted after the first run.
  package { 'toml':
    ensure   => present,
    provider => 'puppetserver_gem',
  }
  # java_ks { 'puppetca:truststore':
  #   ensure       => latest,
  #   certificate  => '/etc/puppet/ssl/certs/ca.pem',
  #   target       => '/etc/activemq/broker.ts',
  #   password     => 'puppet',
  #   trustcacerts => true,
  # }
  #   package { 'foreman-release':
  #   ensure  => absent,
  #   require => Class['foreman'],
  # }

  # Class['scl'] -> Class['foreman']

  # XXX theforeman/puppet does not manage the yumrepo.  puppetlabs/puppet_agent is hardwired
  # to manage the puppet package and conflicts with theforeman/puppet.  We should try to
  # submit support to puppetlabs/puppet_agent for managing only the yumrepo.
  # yumrepo { 'pc_repo':
  #   ensure   => 'present',
  #   baseurl  => 'https://yum.puppet.com/puppet7/el/7/x86_64',
  #   descr    => 'Puppet Labs puppet7 Repository',
  #   enabled  => true,
  #   gpgcheck => '1',
  #   gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet\n  file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
  #   # before   => Class['puppet'],
  # }
}
