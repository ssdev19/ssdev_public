# Java
class profile::java ( String
$version,
$jdk_version,
$j_version,
$version_minor,
$version_major,
$jre_version,
$distribution,
$java_home,
$java_path,
$mem,
){
class { 'java':
  distribution => 'jre',
}


  # java::adopt { 'jdk' :
  #   ensure        => 'present',
  #   version       => $jdk_version,
  #   version_major => $version_major,
  #   version_minor => $version_minor,
  #   java          => 'jdk',
  # }
    # java::adopt { $distribution :
    #   ensure  => 'present',
    #   version => $j_version,
    #   java    => $distribution,
    #   # require => File['/usr/java/jdk-11.0.2+9-jre/lib/security/cacerts']
    # }
  ### export _JAVA_OPTIONS="-Xmx1g"
  exec { 'set java heap size ':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "sudo -s export _JAVA_OPTIONS=${mem}",
  }
  exec { 'set java path':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "sudo -s export PATH=${java_path}",
  }
}
