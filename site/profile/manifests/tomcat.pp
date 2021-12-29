# tomcat 
class profile::tomcat ( String
$catalina_home,
$catalina_base,
$version,
$distribution,
$ciphers,
){
  tomcat::install { $catalina_home:
  source_url     => "https://dlcdn.apache.org/tomcat/${version}.tar.gz",
  }
  tomcat::instance { 'default':
  catalina_home => $catalina_home,
  catalina_base => $catalina_base,
  }
# Getting tomcat::service to work was too painful
  $tomcat_service = @("EOT")
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=syslog.target network.target

    [Service]
    Type=forking
    SuccessExitStatus=143

    Environment=JAVA_HOME=/usr/java/jdk-11.0.2+9
    Environment=CATALINA_PID=${catalina_home}/temp/tomcat.pid
    Environment=CATALINA_HOME=${catalina_home}
    Environment=CATALINA_BASE=${catalina_base}
    Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

    ExecStart=${catalina_home}/bin/startup.sh
    ExecStop=${catalina_home}/bin/shutdown.sh

    User=tomcat
    Group=tomcat

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::unit_file { 'tomcat.service':
    content => $tomcat_service,
  }
  -> service { 'tomcat':
  subscribe => Tomcat::Instance['default'],
  ensure    => 'running',
  enable    => true,
  }
# wait for tomcat service to start 
exec {'wait for tomcat':
  require => Service['tomcat'],
  command => 'sleep 30 && /usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080',
  path    => '/usr/bin:/bin'
}
    # Installs Java in '/usr/java/jdk-11.0.2+9/bin/'
  class { 'java':
    distribution => 'jre',
    version      => 'latest',
    java_home    => '/usr/java/jdk-11.0.2+9',
  }
  java::adopt { 'jdk' :
    ensure  => 'present',
    version => '11',
    java    => 'jdk',
  }
  java::adopt { 'jre' :
    ensure  => 'present',
    version => '8',
    java    => 'jre',
  }
  ### export _JAVA_OPTIONS="-Xmx1g"
  $mem = '-Xmx1g'
  exec { 'set java heap size ':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "sudo -s export _JAVA_OPTIONS=${mem}",
  }
  exec { 'set java path':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => 'sudo -s export PATH=/usr/java/jdk8u202-b08-jre/bin:$PATH',
  }

  # Removes entry in: /opt/tomcat/webapps/manager/META-INF/context.xml
  # For some reason it does not remove it, had to do it manually
  tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
  ensure        => 'absent',
  catalina_base => $catalina_base,
  }
  file { '/opt/tomcat/webapps/manager/META-INF/context.xml':
    ensure => present,
  }
  -> file_line{ 'remove org.apache.catalina.valves.RemoteAddrValve':
      match => 'org.apache.catalina.valves.RemoteAddrValve',
      line  => ' ',
      path  => '/opt/tomcat/webapps/manager/META-INF/context.xml',
    }
  tomcat::config::server::tomcat_users { 'tomcatuser':
    password      => 'tomcatpass',
    roles         => ['admin-gui, manager-gui, manager-script'],
    catalina_base => $catalina_base,
  }

  # setcap cap_net_bind_service+ep /usr/java/jdk-11.0.2+9/bin/java
  # or  setcap cap_net_bind_service+ep /usr/java/jdk8u202-b08-jre/bin/java
  # configure SSL and specify protocols and ciphers to use
  tomcat::config::server::connector { "default-https":
    catalina_base         => $catalina_base,
    port                  => 8443,
    protocol              =>'org.apache.coyote.http11.Http11NioProtocol', # $http_version,
    purge_connectors      => true,
    additional_attributes => {
      'redirectPort'        => absent,
      'SSLEnabled'          => true, # bool2str($https_enabled),
      'maxThreads'          => 150,
      'scheme'              => https,
      'secure'              => true, #bool2str($https_connector_secure),
      'clientAuth'          => 'false',
      'sslProtocol'         => 'TLS',
      'sslEnabledProtocols' => 'TLSv1.2',
      'ciphers'             => $ciphers,

      'keystorePass'        => 'changeit',
      'keystoreFile'        => '/etc/pki/keystore',
    },
  }

}
