## Reboot will be required following the installation of this
class profile::pwm {
  # install awscli tool
  class { 'archive':
    gsutil_install  => true,
    aws_cli_install => true,
  }

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
  # pwm configuration
  $pwmconfig = lookup('pwmconfig')
  file { '/opt/tomcat/webapps/pwm/WEB-INF/PwmConfiguration.xml':
    ensure  => present,
    content => $pwmconfig,
  }
  # $awscreds = lookup('awscreds')
  #   file {
  #     '/root/.aws':
  #       ensure => directory,
  #       mode   => '0700',
  #       ;
  #     '/root/.aws/creds':
  #       ensure  => file,
  #       mode    => '0600',
  #       content => $awscreds,
  #   }
  # # Manage certs
  # java_ks { 'pwm:truststore':
  #   ensure       => latest,
  #   certificate  => '/tmp/ca.cert',
  #   target       => '/usr/java/jdk-11.0.2+9/lib/security/test.cert',
  #   password     => 'passpass', # Must be at least 6 characters
  #   trustcacerts => true,
  # }
}
