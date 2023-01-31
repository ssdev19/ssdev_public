# Java
class profile::grayjava {
  class { 'java':
    distribution => jdk,
    version      => installed,
    # java_home    => $java_home,
  }
  java::adopt { 'jdk11' :
    ensure  => 'latest',
    version => '11',
    # version_major => '2',
    # version_minor => '9',
    java    => 'jdk',
  }
}
