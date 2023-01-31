# Java
class profile::grayjava {
  java::adopt { 'jdk17' :
    ensure  => 'latest',
    version => '17',
    # version_major => '2',
    # version_minor => '9',
    java    => 'jdk',
  }
}
