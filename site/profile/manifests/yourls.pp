# 
class profile::yourls {
  include apache
  include '::php'

  archive { '/tmp/yourls-1.9.2.zip':
    ensure   => present,
    source   => 'https://github.com/YOURLS/YOURLS/archive/refs/tags/1.9.2.zip',
    # extract_path => ,
    provider => 'wget',
    cleanup  => false,
  }
  # file { '/opt/tomcat/webapps/ROOT.war':
  #   ensure => present,
  #   source => '/tmp/pwm-1.9.2.war',
  # }
}
