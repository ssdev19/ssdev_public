#  PingFed config
class profile::pwm {
include 'archive'
  archive { '/tmp/pingfed.zip':
    ensure   => present,
    source   => 'https://project.lsst.org/zpuppet/pingfederate/pingfederate-11.0.2.zip',
    provider => 'wget',
    cleanup  => false,
  }
}
