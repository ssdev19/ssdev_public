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

  archive { '/tmp/pingfed.zip':
    source       => "http://wsus.lsst.org/puppetfiles/pingfederate/pingfederate-${pf_version}.zip",
    cleanup      => true,
    extract      => true,
    extract_path => '/opt',
  }
  # Required for Atlassian connector
    archive { '/tmp/atlassianpingfed.zip':
    source       => 'http://wsus.lsst.org/puppetfiles/pingfederate/pf-atlassian-cloud-connector-1.0.zip',
    cleanup      => true,
    extract      => true,
    extract_path => '/tmp/',
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

  file { "/opt/pingfederate-${pf_version}/pingfederate/server/default/deploy/pf-atlassian-cloud-quickconnection-1.0.jar":
    ensure => present,
    source => '/tmp/pf-atlassian-cloud-connector/dist/pf-atlassian-cloud-quickconnection-1.0.jar',
  }

# $pingservice = '/etc/systemd/system/pingfederate.service'
# $file_exists = find_file($pingservice)
# if $file_exists {
#   notify{"service exists at ${file_exists}.":}
# } else {
#   notify{"service ${pingservice} does not exists.${file_exists}":}
      # recursive_file_permissions {'/opt/pingfederate-11.0.2/pingfederate/':
      #   file_mode => '0775',
      #   dir_mode  => '0775',
      #   owner     => $pf_user,
      #   group     => $pf_user,
      #   }
# }


  # Copy file needed for Atlassian connector & modify run.properties
  file { "/opt/pingfederate-${pf_version}/pingfederate/bin/run.properties":
    ensure => file,
  }
  -> file_line{ 'change pf.provisioner.mode to STANDALONE':
      match => 'pf.provisioner.mode=OFF',
      line  => 'pf.provisioner.mode=STANDALONE',
      path  => "/opt/pingfederate-${pf_version}/pingfederate/bin/run.properties",
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
  archive { '/tmp/log4j2.xml' :
    ensure  => present,
    source  => 's3://pingfe/log4j2.xml',
    cleanup => false,
  }

  file { "/opt/pingfederate-${pf_version}/pingfederate/server/default/conf/log4j2.xml":
  ensure  => present,
  source  => '/tmp/log4j2.xml',
  replace => 'yes',
  }


  # Pingfederate service /etc/systemd/system/pingfederate.service
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
    $pf_lic = lookup('pf_lic')
  #   file { '/opt/pingfederate-11.0.2/pingfederate/server/default/conf/pf/pingfederate.lic':
  #   ensure  => present,
  #   source  => $pf_lic,
  #   replace => 'no',
  # }
  archive { "/opt/pingfederate-${pf_version}/pingfederate/server/default/conf/pingfederate.lic" :
    ensure  => present,
    source  => $pf_lic,
    cleanup => false,
  }
 $file_path = '/opt/pingfederate-11.0.2/pingfederate/bin/start.ini' 
 $file_exists = find_file($file_path)
 if $file_exists {
   notify{"File ${file_path} exist":}
 } else {  
    recursive_file_permissions { "/opt/pingfederate-${pf_version}/pingfederate/":
      file_mode => '0775',
      dir_mode  => '0775',
      owner     => $pf_user,
      group     => $pf_user,
    }
 }
  # Backup logs
  # archive { '/tmp/ssolog' :
  #   ensure  => present,
  #   source  => '/opt/pingfederate-11.0.2/pingfederate/log',
  #   cleanup => false,
  # }
}
