# https://download.support.xerox.com/pub/docs/docushare/userdocs/any-os/en_GB/install_gde652.pdf 
class profile::docushare {
include 'archive'

#download docushare
  file {
    '/opt/xerox':
      ensure => directory,
  }
  archive { '/tmp/docushare.tar.gz':
    source       => 'https://download.support.xerox.com/pub/drivers/docushare/utils/wins2016x64/en_GB/ds750-b215-linux.tar.gz',
    cleanup      => true,
    extract      => true,
    extract_path => '/opt/xerox',
  }
  $path = '$PATH:/opt/xerox/Linux/DocuShare'
  exec { '$PATH:/opt/xerox/Linux/DocuShare':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    # command => "export PATH=${path}",
  }

}
