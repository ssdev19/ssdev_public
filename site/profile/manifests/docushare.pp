# https://download.support.xerox.com/pub/docs/docushare/userdocs/any-os/en_GB/install_gde652.pdf
class profile::docushare {
include 'archive'

#download docushare
  archive { '/tmp/docushare.tar.gz':
    # ensure   => present,
    source       => 'https://download.support.xerox.com/pub/drivers/docushare/utils/wins2016x64/en_GB/ds750-b215-linux.tar.gz',
    # provider => 'wget',
    cleanup      => true,
    extract      => true,
    extract_path => '/opt/',
  }

}
