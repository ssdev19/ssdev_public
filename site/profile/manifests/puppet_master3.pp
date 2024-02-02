# puppet master config
class profile::puppet_master3 {
  # include r10k
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
  yumrepo { 'pc_repo':
    ensure   => 'present',
    baseurl  => "http://yum.puppet.com/puppet7/el/${fact('os.release.major')}/x86_64",
    descr    => 'Puppet Labs puppet7 Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet\n  file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
    # before   => Class['puppet'],
  }
  # file { '/etc/puppetlabs/puppet/eyaml' :
  #   ensure  => directory,
  # }
  # class { 'puppet':
  #   server              => true,
  #   server_reports      => 'puppetdb,foreman',
  #   server_storeconfigs => true,
  # }
  # include puppetdb
  # class { 'puppet::server::puppetdb':
  #   server => 'foreman-rl8.us.lsst.org',
  # }
}
