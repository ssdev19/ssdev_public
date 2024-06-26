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
  # include puppet
  Package {['make']:
    ensure => installed,
  }
  package { 'toml':
    ensure   => present,
    provider => 'puppetserver_gem',
  }
  package { 'hiera-eyaml':
    ensure   => latest,
    provider => 'puppetserver_gem',
  }
  # package { 'eyaml':
  #   ensure   => '3.2.0',
  #   provider => 'puppetserver_gem',
  # }

  $prkpem = lookup('prkpem')
  $pukpem = lookup('pukpem')
  file {
    '/etc/puppetlabs/puppet/eyaml':
      ensure => directory,
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0500',
      ;
    '/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0400',
      content => $prkpem,
      ;
    '/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0400',
      content => $pukpem,
      ;
  }
  # yumrepo { 'pc_repo':
  #   ensure   => 'present',
  #   baseurl  => "http://yum.puppet.com/puppet7/el/${fact('os.release.major')}/x86_64",
  #   descr    => 'Puppet Labs puppet7 Repository',
  #   enabled  => true,
  #   gpgcheck => '1',
  #   gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet\n  file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-20250406",
  #   before   => Class['puppet'],
  # }
  # class { 'r10k':
  #   remote   => 'git@github.com:ssdev19/ssdev_public',
  #   provider => 'puppet_gem',
  # }
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
