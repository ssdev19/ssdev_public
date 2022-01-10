# Java
class profile::java ( String
$version,
$jdk_version,
$jre_version,
$distribution,
$java_home,
$java_path,
$mem,
){  class { 'java':
    distribution => $distribution,
    version      => 'latest',
    java_home    => $java_home,
  }
  java::adopt { 'jdk' :
    ensure  => 'present',
    version => $jdk_version,
    java    => 'jdk',
  }
  java::adopt { 'jre' :
    ensure  => 'present',
    version => $jre_version,
    java    => 'jre',
  }
  ### export _JAVA_OPTIONS="-Xmx1g"
  # $mem = '-Xmx1g'
  exec { 'set java heap size ':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "sudo -s export _JAVA_OPTIONS=${mem}",
  }
  exec { 'set java path':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "sudo -s export PATH=${java_path}:$PATH",
  }
