## Reboot will be required following the installation of this
class profile::pwm {
  # include firewalld
  archive { '/tmp/pwm-1.9.2.war':
    ensure   => present,
    source   => 'https://github.com/pwm-project/pwm/releases/download/v1_9_2/pwm-1.9.2.war',
    provider => 'wget',
    cleanup  => false,
  }
  file { '/opt/tomcat/webapps/pwm.war':
    ensure => present,
    source => '/tmp/pwm-1.9.2.war',
  }
  $applicationpath = lookup('application_path')
  $webpath = lookup('web_path')
  file { '/opt/tomcat/webapps/pwm/WEB-INF/web.xml':
    ensure => present,
  }
  -> file_line { 'Append a line to pwm/WEB-INF/web.xml':
      path  => $webpath,
      line  => "<param-value>${applicationpath}</param-value>",
      match => '<param-value>unspecified</param-value>', # "^unspecified.*$" can be used for string
    }
# download MS sqljdbc 
  archive { '/tmp/sqljdbc_6.2.2.1_enu.tar.gz':
    ensure   => present,
    source   => 'https://download.microsoft.com/download/3/F/7/3F74A9B9-C5F0-43EA-A721-07DA590FD186/sqljdbc_6.2.2.1_enu.tar.gz',
    provider => 'wget',
    extract  => true,
    cleanup  => false,
  }
# Manage certs
java_ks { 'pwm:truststore':
  ensure       => latest,
  certificate  => '/tmp/ca.cert',
  target       => '/usr/java/jdk-11.0.2+9/lib/security/test.cert',
  password     => 'passpass', # Must be at least 6 characters
  trustcacerts => true,
}
}
