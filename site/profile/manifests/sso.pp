#  PingFed config
class profile::sso ( String
$pf_user,
# $pf_pass,
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
    cleanup      => true,
    # user         => $pf_user,
    extract      => true,
    extract_path => '/opt',
  }
  archive { '/tmp/jirapingfed.zip':
    # ensure   => present,
    source       => 'https://pingfe.s3.us-east-1.amazonaws.com/pingfederate-data-06-15-2022_sso.lsst.org.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEL7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLXdlc3QtMSJHMEUCIEWNKyy9ZplaYjwqZwSvu0OiaQb4ztiazkm5nCcOZOc%2FAiEAp8v9YfU%2Bh9WoxKxKtc%2FQTjooU7267b40RYYoAtZBnhsqhAMI1%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgwxMzM0MjgwMjU1MTkiDASNUThLcrNy4OacbCrYAgp%2FPt7ZasIr3l9iiNJ4TDxRiLQaXbKCj9rF0UnXYlVHb1zY%2BuS8tm0abMHISwKdNQXVKYrNhWAnLwm%2FQvfcwQJlbVZOO8bSwkz8A0LF2q4jewUZKQjHwfr8RPuTW8zydrFeaRORK6%2BfHAopvsuDjzSNhbbCJArZZJLDPXrFSGimDRD8Fca%2BOaUNdg55Ld%2BtFFz9yn6QQPPVAgF4E2KJV8pAI%2FBGuq2MuPEU7BlGGYCgdjtmI1vYLbT4QrvInuBVxs6rTsfVy0xxeSOJCt%2FYsIA0EGJN6tjXeoekk2MsDfjuNHf6xCkXZUZh05IYF0pnL96rcEm8M%2BZRIleM9ZXSKuvQoU2qtJQcIuHlosz%2B05gZeZMLPVmXNEaF0LWgWBA1io8eYzDffJ480Nij3%2BktD8PC75%2BptQemcBS%2FBfs8qphK6E7zufNFG1wxgBRYtIczaOofIsqYo1fJMOP05pUGOrMCPYXTRxdx49BkCE7nubJgKBOLuSdPLRa7ofogTlNwDZKiE1%2BkThnkoB8J1e0ym68gyvJSCr5YQo%2FBLsLjVyVaS75WBlXK%2FzkHVFZBCtaGD476dmQnOT9T4W0ghrvo%2FXxVw7CyK4YGEwGr3xhWN4%2B4wac6oFHIn0LVoY%2B0XntU10cQrCj4vVcolX3st1M1eEh5vR6UKj%2BDBaMZgkJ6iBhyLS9ESI9lEy8LulNyyYrftd7Kfp5pXgahEiSObwuXFMydkk%2FLdXRIxh7za%2BGVkUUcgyt8yNnrklbAxKcGCAg%2BtqjfJwpxprJ2%2FoxNHbYf11mk2a0nKzCrvyg8y1BnF6u2i1T47NhxndCtrhl3YiLA6rnwZPTAwX5EO6MpUVvya5lXqI%2B73rurPINIxQpgv0UFfS5ybg%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220627T141356Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAR6EHODCXVE2UEP72%2F20220627%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=1bbc9b14c3223ef04413994cec4a0a173c886c955cb9af105de3b1afb7128eca',
    # provider => 'wget',
    cleanup      => true,
    # user         => $pf_user,
    extract      => true,
    extract_path => '/opt/pingfederate-11.0.2/pingfederate/server/default/deploy',
  }

  file { '/opt/pingfederate-11.0.2/pingfederate/bin/run.properties':
    ensure => file,
  }
  -> file_line{ 'change pf.provisioner.mode to STANDALONE':
      match => 'pf.provisioner.mode=OFF',
      line  => 'pf.provisioner.mode=STANDALONE',
      path  => '/opt/pingfederate-11.0.2/pingfederate/bin/run.properties',
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
}
