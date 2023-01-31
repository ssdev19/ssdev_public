# Java
class profile::grayjava {
  class { 'java':
    distribution => 'jre',
    version      => 'latest',
    # java_home    => $java_home,
  }
  java::adopt { 'jdk11' :
    ensure  => 'latest',
    version => '17',
    # version_major => '2',
    # version_minor => '9',
    java    => 'jdk',
  }
}
