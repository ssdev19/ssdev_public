# Java
class profile::grayjava {
  java::adopt { 'jdk11' :
    ensure  => 'latest',
    version => '11',
    java    => 'jdk',
  }
}
