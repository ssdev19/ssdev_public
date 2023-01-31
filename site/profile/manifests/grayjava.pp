# Java
class profile::grayjava {
  java::adopt { 'jdk11' :
    ensure  => 'present',
    version => '11',
    java    => 'jdk',
  }
}
