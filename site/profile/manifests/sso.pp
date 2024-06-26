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
  unless $::pf_svc  {
    archive { '/tmp/pingfed.zip':
      source       => "http://wsus.lsst.org/puppetfiles/pingfederate/pingfederate-${pf_version}.zip",
      cleanup      => false,
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
      # extract_path => '/opt/pingfederate-11.0.7/pingfederate/server/default/deploy',
      extract_path => '/tmp/',
      # creates      => '/tmp/atlassianconnector' 
    }
    # zoom provisioner /opt/pingfederate-11.0.7/pingfederate/server/default/deploy/
    archive { '/opt/pingfederate-11.0.7/pingfederate/server/default/deploy/pf-zoom-quickconnection-1.0.jar':
      source   => 'http://wsus.lsst.org/puppetfiles/pingfederate/pf-zoom-quickconnection-1.0.jar',
      cleanup  => false,
    }
    recursive_file_permissions { $pf_home:
      file_mode => '0775',
      dir_mode  => '0775',
      owner     => $pf_user,
      group     => $pf_user,
    }
  }
  file { "/opt/pingfederate-${pf_version}/pingfederate/server/default/deploy/pf-zoom-quickconnection-1.0.jar":
    ensure => present,
    source => '/tmp/pf-zoom-connector/dist/pf-zoom-quickconnection-1.0.jar',
  }

  file { "/opt/pingfederate-${pf_version}/pingfederate/server/default/deploy/pf-atlassian-cloud-quickconnection-1.0.jar":
    ensure => present,
    source => '/tmp/pf-atlassian-cloud-connector/dist/pf-atlassian-cloud-quickconnection-1.0.jar',
  }


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
  # file { '/opt/pingfederate-11.0.7/pingfederate/server/default/conf/log4j2.xml':
  #   ensure => file,
  # }
  # -> file_line{ 'Syslog config':
  #     match => $match,
  #     line  => $line,
  #     path  => '/opt/pingfederate-11.0.7/pingfederate/server/default/conf/log4j2.xml',
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
  $pf_lic = lookup('pf_lic')
  #   file { '/opt/pingfederate-11.0.7/pingfederate/server/default/conf/pf/pingfederate.lic':
  #   ensure  => present,
  #   source  => $pf_lic,
  #   replace => 'no',
  # }
  archive { "/opt/pingfederate-${pf_version}/pingfederate/server/default/conf/pingfederate.lic" :
    ensure  => present,
    source  => $pf_lic,
    cleanup => false,
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


  
# Vulnerability check 2/22/2023
  # archive { '/tmp/pf-security-advisory.zip':
  #   source       => "http://wsus.lsst.org/puppetfiles/pingfederate/pf-security-advisory-utility-assembly-SECADV033-1.0.zip",
  #   cleanup      => true,
  #   extract      => true,
  #   extract_path => '/opt/pingfederate-11.0.7/pingfederate/bin',
  # }



}
