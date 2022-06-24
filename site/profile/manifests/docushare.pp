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
  file { '/opt/xerox/Linux/DocuShare/docushare':
    mode    => 644,
    content => 'PATH=$PATH:/opt/xerox/Linux/DocuShare',
  }
  # $path = '$PATH:/opt/xerox/Linux/DocuShare'
  # exec { 'set DocuShare path':
  #   path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
  #   command => "PATH=${path}",
  # }

}
