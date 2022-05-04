#  PingFed config
class profile::sso {
include 'archive'
    file {
      '/opt/pingfederate':
        ensure => directory,
    }
  archive { '/tmp/pingfed.zip':
    # ensure   => present,
    source       => 'https://project.lsst.org/zpuppet/pingfederate/pingfederate-11.0.2.zip',
    # provider => 'wget',
    cleanup      => false,
    extract      => true,
    extract_path => '/opt/pingfederate',
  }
  
}
