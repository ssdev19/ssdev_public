## Reboot will be required following the installation of this
class profile::pwm {
  # include firewalld
  archive { '/tmp/pwm.war':
    ensure   => present,
    source   => 'https://github.com/pwm-project/pwm/releases/download/v1_9_2/pwm-1.9.2.war',
    provider => 'wget',
    cleanup  => false,
  }
  file { '/tmp/pwm.war':
    ensure => present,
    source => '/opt/tomcat/webapps/pwm.war',
  }
}
