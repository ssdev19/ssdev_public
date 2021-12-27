# Base profile for Linux OS
class profile::base_linux {
  include network
  include ::firewalld
  include ssh
  include accounts
  include cron
  include rsyslog
  include rsyslog::config
# config: /etc/systemd/system/node_exporter.service
  class { 'prometheus::node_exporter':
    version       => '1.1.2',
    extra_options => '--collector.systemd \--collector.processes \--collector.meminfo_numa',
  }
  #   $fqdn = $::facts['networking']['fqdn']
  # @@profile::prometheus::target { "${fqdn} - node_exporter":
  #   job  => 'node',
  #   host => "${fqdn}:9100",
  # }
  class { 'ntp':
    servers => [ '140.252.1.140', '140.252.1.141', '0.pool.ntp.arizona.edu' ],
  }
  class { 'timezone':
      timezone => 'UTC',
  }
  Package { [ 'git', 'tree', 'tcpdump', 'telnet', 'lvm2', 'gcc', 'xinetd',
  'bash-completion', 'sudo', 'screen', 'vim', 'openssl', 'openssl-devel',
  'acpid', 'wget', 'nmap', 'iputils', 'bind-utils', 'traceroute', 'glibc' ]:
  ensure => installed,
  }
# Modify these files to secure servers
  $host = lookup('host')
  file { '/etc/host.conf' :
    ensure  => file,
    content => $host,
  }
  $nsswitch = lookup('nsswitch')
  file { '/etc/nsswitch.conf' :
    ensure  => file,
    content => $nsswitch,
  }
  $sshd_banner = lookup('sshd_banner')
  file { '/etc/ssh/sshd_banner' :
    ensure  => file,
    content => $sshd_banner,
  }
  $denyhosts = lookup ('denyhosts')
  file { '/etc/hosts.deny' :
    ensure  => file,
    content => $denyhosts,
  }
  $allowhosts = lookup ('allowhosts')
  file { '/etc/hosts.allow' :
    ensure  => file,
    content => $allowhosts,
  }
}
