# Base profile for Linux OS
# @param backups
#  If true will deploy backup scripts
# @param awscli
#  If true will install and configure awscli
# @param postfix
#  If `true`, configure postfix
# @param graylog
#  If `true`, configure graylog
# @param network
#  If `true`, configure network
# @param nsswitch
#  If `true`, configure nsswitch
# @param ntp
class profile::base_linux (
  # $service1,
  Boolean $awscli   = false,
  Boolean $backups  = false,
  Boolean $postfix  = true,
  Boolean $graylog  = false,
  Boolean $network  = false,
  Boolean $nsswitch = false,
  Boolean $ntp      = false,
) {
  # include archive
  if $network {
    include ::network
    create_resources('network_config', hiera('network_config'))
  }
  include firewalld
  include ssh
  include accounts
  include cron
  # include facter
  # include ::collectd
  include puppet_agent
  # include nsswitch
  if $postfix {
    include postfix
  }
  if $graylog {
    include rsyslog
    include rsyslog::config
  }
  # $snmp = lookup('snmp')
  # class { 'snmp':
  #   # agentaddress => [ 'udp:161', ],
  #   ro_community => $snmp,
  #   # ro_network   => '140.252.32.0/22',
  # }

# config: /etc/systemd/system/node_exporter.service
  class { 'prometheus::node_exporter':
    version       => '1.7.0',
    extra_options => '--collector.systemd \--collector.processes \--collector.meminfo_numa',
  }

  class { 'chrony':
    servers => ['140.252.1.140', '140.252.1.141', '0.pool.ntp.arizona.edu', 'time.aws.com'],
  }
  # }
  class { 'timezone':
    timezone => 'UTC',
  }
  Package {['git', 'tree', 'tcpdump', 'telnet', 'lvm2',
      'bash-completion', 'sudo', 'vim',  #'openssl', 'openssl-devel',
      'acpid', 'wget', 'nmap', 'iputils', 'bind-utils', 'traceroute',
    'gzip', 'tar', 'unzip', 'net-tools', 'tmux']:
      ensure => installed,
  }
# install awscli tool
# class { 'awscli': }
  if $awscli {
    # class { 'awscli': }
    Package {['python3-pip', 'python3-devel']:
      ensure => installed,
    }
    exec { 'Install awscli':
      path    => ['/usr/bin', '/bin', '/usr/sbin'],
      command => 'sudo pip3 install awscli',
      onlyif  => '/usr/bin/test ! -x /usr/local/bin/aws',
    }
    $awscreds = lookup('awscreds')
    file {
      '/root/.aws':
        ensure => directory,
        mode   => '0700',
        ;
      '/root/.aws/credentials':
        ensure  => file,
        mode    => '0600',
        content => $awscreds,
        ;
      '/root/.aws/config':
        ensure  => file,
        mode    => '0600',
        content => "[default]\n",
    }
  }
# Modify these files to secure servers
  $host = lookup('host')
  file { '/etc/host.conf' :
    ensure  => file,
    content => $host,
  }
  if $nsswitch {
    class { 'nsswitch':
      hosts  => ['dns myhostname','files'],
    }
  }
  # $nsswitch = lookup('nsswitch')
  # file { '/etc/nsswitch.conf' :
  #   ensure  => file,
  #   content => $nsswitch,
  # }
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

  # if $backups {
  #   # $year_month_day = inline_template('<%= Time.now.strftime("%Y-%m-%d") -%>')
  #   file { "/backups/${service1}":
  #       ensure => 'directory',
  #       # target => "/backups/${service1}/${year_month_day}",
  #       ;
  #     '/backups/dumps/':
  #       ensure => directory,
  #       ;
  #     '/backups/scripts/':
  #       ensure => directory,
  #       ;

  # }
  # Changes root's prompt color to cyan (36)
  # file { '/root/.bashrc':
  #   ensure => present,
  # }
  # -> file_line { 'Append a line to /root/.bashrc':
  #   path => '/root/.bashrc',
  #   line => 'export PS1= "\e[0;36m[\u@\h \W]\$ \e[0m"',
  # }
}
