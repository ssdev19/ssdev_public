## Reboot will be required following the installation of this
class profile::pwmrl8 {
include 'archive'
include java_ks::config
  $pwmconfig_dest = lookup('pwmconfig_dest')
  $pwmrl8config_source = lookup('pwmrl8config_source')
  archive { '/tmp/pwm-1.9.2.war':
    ensure   => present,
    source   => 'https://github.com/pwm-project/pwm/releases/download/v1_9_2/pwm-1.9.2.war',
    provider => 'wget',
    cleanup  => false,
  }
  file { '/opt/tomcat/webapps/ROOT.war':
    ensure => present,
    source => '/tmp/pwm-1.9.2.war',
  }
  # using archive directly to destination breaks tomcat installation
  # So it must first go to the tmp folder then compied over to destination.
  archive { '/tmp/PwmConfiguration.xml' :
    ensure  => present,
    source  => $pwmrl8config_source,
    cleanup => false,
  }
  $dc3cert = lookup('dc3cert')
  archive { '/tmp/dc3April22.cer' :
    ensure  => present,
    source  => $dc3cert,
    cleanup => false,
  }
  # keytool -import -keystore cacerts -file /tmp/dc3April22.cer -alias dc3.lsst.local
  $pwmkeystore = lookup('pwmkeystore')
  archive { '/etc/pki/keystore' :
    ensure  => present,
    source  => $pwmkeystore,
    cleanup => false,
  }
  $domaincert = lookup('domaincert')
  archive { '/tmp/lsstcertlatest.crt' :
    ensure  => present,
    source  => $domaincert,
    cleanup => false,
  }
  $domaincert2 = lookup('domaincert2')
  archive { '/tmp/lsstcertlatest.key' :
    ensure  => present,
    source  => $domaincert2,
    cleanup => false,
  }
  $keystorepwd = lookup('keystorepwd')
  java_ks { 'lsst.org:/etc/pki/keystore':
    ensure              => latest,
    certificate         => '/tmp/lsstcertlatest.crt',
    private_key         => '/tmp/lsstcertlatest.key',
    password            => $keystorepwd,
    password_fail_reset => true,
  }
  file { $pwmconfig_dest:
    ensure => present,
    source => '/tmp/PwmConfiguration.xml',
  }

$applicationpath = lookup('application_path')
  $webpath = lookup('web_path')
  file { '/opt/tomcat/webapps/ROOT/WEB-INF/web.xml':
    ensure => present,
  }
  -> file_line { 'Append line to ROOT/WEB-INF/web.xml':
      path  => $webpath,
      line  => "<param-value>${applicationpath}</param-value>",
      match => '<param-value>unspecified</param-value>', # "^unspecified.*$" can be used for string
    }
    $lsst_theme = lookup('lsst_theme')
    file {
      '/opt/tomcat/webapps/ROOT/public/resources/themes/lsst':
        ensure => directory,
    }
    archive { '/tmp/lsst.zip' :
      # path => '/tmp/lsst.zip',
      # ensure  => present,
      source       => $lsst_theme,
      cleanup      => false,
      extract      => true,
      extract_path => '/opt/tomcat/webapps/ROOT/public/resources/themes/lsst',
      # creates      => '/opt/tomcat/webapps/ROOT/public/resources/themes/lsst',
      # require      => File['/opt/tomcat/webapps/ROOT/public/resources/themes/lsst'],
    }
  $favicon = lookup('favicon')
  file { '/opt/tomcat/webapps/ROOT/public/resources/favicon.png':
    ensure => present,
    source => $favicon,
  }

  # # Manage certs
  # java_ks { 'pwm:truststore':
  #   ensure       => latest,
  #   certificate  => '/tmp/ca.cert',
  #   target       => '/usr/java/jdk-11.0.2+9/lib/security/test.cert',
  #   password     => 'passpass', # Must be at least 6 characters
  #   trustcacerts => true,
  # }
}
