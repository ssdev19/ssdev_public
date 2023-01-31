# Java
class profile::grayjava {
  java::adopt { 'jdk11' :
    ensure  => 'latest',
    version => '11',
    version_major => '2',
    version_minor => '9',
    java    => 'jdk',
  }
}
