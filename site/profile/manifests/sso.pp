#  PingFed config
class profile::sso ( String
$pf_user,
$pf_pass,
$java_home,
$pf_home,
$pf_version,
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
    cleanup      => false,
    user         => $pf_user,
    extract      => true,
    extract_path => '/opt',
  }

  # exec {'Install pingfed':
  # command  => '/opt/pingfederate-11.0.2/pingfederate/bin/run.sh',
  # provider => shell,
  # # onlyif   => '/usr/bin/test -e /path/to/file/test.txt',
  # }
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
    file {
      $pf_home:
      ensure => directory,
      owner  => $pf_user,
      # group  => $pf_user,
      mode   => '0775',
    }
}
