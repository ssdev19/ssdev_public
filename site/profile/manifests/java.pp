# Java
# @param version
#  Java Version
# @param jdk_version
#  jdk version
# @param version_minor
#  Java version minor
# @param version_major
#  Java version major
# @param jre_version
#  JRE version
# @param distribution
#  Java distributin
# @param java_home
#  Java HOME location
# @param java_path
#  Java path
# @param mem
#  Java memory allocation
class profile::java (
  String $version,
  String $jdk_version,
  String $version_minor,
  String $version_major,
  String $jre_version,
  String $distribution,
  String $java_home,
  String $java_path,
  String $mem,
) {
  class { 'java':
    distribution => $distribution,
    version      => $version,
    java_home    => $java_home,
  }
  # java::adopt { 'jdk' :
  #   ensure        => 'present',
  #   version       => $jdk_version,
  #   version_major => $version_major,
  #   version_minor => $version_minor,
  #   java          => 'jdk',
  # }
  java::adopt { 'jdk' :
    ensure        => 'present',
    version       => $j_version,
    java          => $distribution,
    version_major => $version_major,
    version_minor => $version_minor,
    # basedir => '/usr/java/',
  }
  ### export _JAVA_OPTIONS="-Xmx1g"
  # exec { 'set java heap size ':
  #   path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
  #   command => "sudo -s export _JAVA_OPTIONS=${mem}",
  # }
  # exec { 'set java path':
  #   path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
  #   command => "sudo -s export PATH=${java_path}",
  # }
}
