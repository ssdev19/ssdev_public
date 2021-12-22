# tomcat 
class profile::tomcat ( String
$catalina_home,
$catalina_base,
$version,
$distribution,
){
  tomcat::install { $catalina_home:
  source_url     => "https://dlcdn.apache.org/tomcat/${version}.tar.gz",
  }
  tomcat::instance { 'default':
  catalina_home => $catalina_home,
  catalina_base => $catalina_base,
  }
    # Installs Java in '/usr/java/jdk-11.0.2+9/bin/'
  class { 'java':
    distribution => $distribution,
    version      => 'latest',
    java_home    => '/usr/java/jdk8u202-b08-jre',
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
    command => 'sudo -s export PATH=/usr/java/jdk-11.0.2+9/bin:$PATH',
  }

  # Removes entry in: /opt/tomcat/webapps/manager/META-INF/context.xml
  # For some reason it does not remove it, had to do it manually
  tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
  ensure        => 'absent',
  catalina_base => '/opt/tomcat',
  }
  file { '/opt/tomcat/webapps/manager/META-INF/context.xml':
    ensure => present,
  }
  -> file_line{ 'org.apache.catalina.valves.RemoteAddrValve':
      match => 'org.apache.catalina.valves.RemoteAddrValve',
      line  => ' ',
      path  => '/opt/tomcat/webapps/manager/META-INF/context.xml',
    }
  tomcat::config::server::tomcat_users { 'tomcatuser':
    password      => 'tomcatpass',
    roles         => ['admin-gui, manager-gui, manager-script'],
    catalina_base => '/opt/tomcat',
  }
  # tomcat::service {'tomcat':
  #   # catalina_home  => '/opt/tomcat/',
  #   catalina_base  => '/opt/tomcat/',
  #   catalina_home  => '/opt/tomcat/',
  #   use_init       => true,
  #   java_home      => '/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-1.el7_9.x86_64/jre/',
  #   user           => 'tomcat',
  #   service_enable => true,
  #   service_name   => 'tomcat',
  #   service_ensure => running,
  #   start_command  => 'use_init',
  # }
  # tomcat::config::server::tomcat_users {'/opt/tomcat/conf/tomcat-users.xml':
  #   password => 'tomcatpass',
  # }
}
