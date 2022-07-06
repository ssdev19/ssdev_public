#  PingFed config
class profile::sso ( String
$pf_user,
# $pf_pass,
$java_home,
$pf_home,
$pf_version,
$match,
$line,
){
  # user { $pf_user:
  #   ensure   => present,
  #   password => $pf_pass
  # }
include 'archive'

  archive { '/tmp/pingfed.zip':
    # ensure   => present,
    source       => 'https://project.lsst.org/zpuppet/pingfederate/pingfederate-11.0.2.zip',
    # provider => 'wget',
    cleanup      => true,
    # user         => $pf_user,
    extract      => true,
    extract_path => '/opt',
  }
  archive { '/tmp/jirapingfed.zip':
    # ensure   => present,
    source       => 'https://project.lsst.org/zpuppet/pingfederate/pf-atlassian-cloud-connector-1.0.zip',
    # provider => 'wget',
    cleanup      => true,
    # user         => $pf_user,
    extract      => true,
    # extract_path => '/opt/pingfederate-11.0.2/pingfederate/server/default/deploy',
    extract_path => '/tmp/',
    # creates      => '/tmp/atlassianconnector'
  }

  file { '/opt/pingfederate-11.0.2/pingfederate/server/default/deploy/pf-atlassian-cloud-quickconnection-1.0.jar':
    ensure => present,
    source => '/tmp/pf-atlassian-cloud-connector/dist/pf-atlassian-cloud-quickconnection-1.0.jar',
  }
  # Copy file needed for Atlassian connector & modify run.properties
  file { '/opt/pingfederate-11.0.2/pingfederate/bin/run.properties':
    ensure => file,
  }
  -> file_line{ 'change pf.provisioner.mode to STANDALONE':
      match => 'pf.provisioner.mode=OFF',
      line  => 'pf.provisioner.mode=STANDALONE',
      path  => '/opt/pingfederate-11.0.2/pingfederate/bin/run.properties',
    }
  # Send audit logs to graylog
  # file { '/opt/pingfederate-11.0.2/pingfederate/server/default/conf/log4j2.xml':
  #   ensure => file,
  # }
  # -> file_line{ 'Syslog config':
  #     match => $match,
  #     line  => $line,
  #     path  => '/opt/pingfederate-11.0.2/pingfederate/server/default/conf/log4j2.xml',
  #   }
  # Pingfederate service
  $pingfederate_service = @("EOT")
    [Unit]
    Description=PingFederate ${pf_version}
    Documentation=https://support.pingidentity.com/s/PingFederate-help

    [Install]
    WantedBy=multi-user.target

    [Service]
    Type=simple
    User=${pf_user}
    WorkingDirectory=${pf_home}
    Environment='JAVA_HOME=${java_home}'
    ExecStart=${pf_home}/bin/run.sh

    | EOT
# 
  systemd::unit_file { 'pingfederate.service':
    content => "${pingfederate_service}",
    mode => '0664',
  }
  -> service { 'pingfederate':
  # subscribe => Pingfederate::Instance['default'],
  ensure    => 'running',
  enable    => true,
  }
#     file {
#       $pf_home:
#       ensure => directory,
#       owner  => $pf_user,
#       # group  => $pf_user,
#       mode   => '0775',
#       recurse => true,
#     }
  recursive_file_permissions { '/opt/pingfederate-11.0.2/pingfederate/':
    file_mode => '0775',
    dir_mode  => '0775',
    owner     => $pf_user,
    group     => $pf_user,
  }
  $pf_lic = lookup('pf_lic')
  #   file { '/opt/pingfederate-11.0.2/pingfederate/server/default/conf/pf/pingfederate.lic':
  #   ensure  => present,
  #   source  => $pf_lic,
  #   replace => 'no',
  # }
  archive { '/opt/pingfederate-11.0.2/pingfederate/server/default/conf/pingfederate.lic' :
    ensure  => present,
    source  => $pf_lic,
    cleanup => false,
  }
  # Backup logs
  # archive { '/tmp/ssolog' :
  #   ensure  => present,
  #   source  => '/opt/pingfederate-11.0.2/pingfederate/log',
  #   cleanup => false,
  # }
}
