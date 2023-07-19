# 
class profile::yourls {
  include nginx
  include '::php'

  # unless $::yourls_config  {
  # archive { '/tmp/yourls-1.9.2.zip':
  #   ensure       => present,
  #   source       => 'https://github.com/YOURLS/YOURLS/archive/refs/tags/1.9.2.zip',
  #   extract_path => '/var/www',
  #   extract      => true,
  #   provider     => 'wget',
  #   cleanup      => false,
  # }
  # file { '/var/www/YOURLS-1.9.2/user/config.php':
  #           ensure => present,
  #           source => '/var/www/YOURLS-1.9.2/user/config-sample.php',
  # }
  # }
}
