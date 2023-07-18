# 
class profile::yourls {
  include apache
  include '::php'

  unless $::yourls_config  {
  archive { '/tmp/yourls-1.9.2.zip':
    ensure       => present,
    source       => 'https://github.com/YOURLS/YOURLS/archive/refs/tags/1.9.2.zip',
    extract_path => '/var/www',
    extract      => true,
    provider     => 'wget',
    cleanup      => false,
  }
  # file { '/opt/tomcat/webapps/ROOT.war':
  #   ensure => present,
  #   source => '/tmp/pwm-1.9.2.war',
  # }
  }
}
